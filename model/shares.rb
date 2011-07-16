require_relative "../lib/namecoiner"
require_relative "../lib/namecoiner/block_header"
require 'dalli'
require 'sequel'
require 'json'

module Namecoiner
  config = JSON.load(File.read(File.expand_path('~/server.json')))
  dbc = config['database']
  adapter_map = {'postgresql' => 'postgres', 'mysql' => 'mysql'}

  DB = Sequel.connect(
    adapter: adapter_map.fetch(dbc.fetch('engine')),
    host: dbc.fetch('host'),
    port: dbc.fetch('port'),
    user: dbc.fetch('username'),
    password: dbc.fetch('password'),
    database: dbc.fetch('name'))

  class Shares < Sequel::Model
    set_dataset :shares # for better reloading
    one_to_many :payout, :key => :found_block

    plugin :caching, Dalli::Client.new, ttl: 10

    def self.average_time_per_round
      all = won_shares.order(:created_at.asc).all
      Rational((all.last.created_at - all.first.created_at)/all.size,60).divmod(60)
    end

    def self.average_shares_per_round
      won = won_shares.count
      count / won
    end

    def self.ghash_per_sec_for(username)
      DB["SELECT COUNT(*) * POW(2,32) / 600 as hash FROM shares WHERE created_at+'600 seconds'::text::interval > NOW() AND our_result = 'Y' and username = ?", username].first[:hash]
    end

    def self.hash_per_second
      DB["SELECT COUNT(*) * POW(2,32) / 600 as hash FROM shares WHERE created_at+'600 seconds'::text::interval > NOW() AND our_result = 'Y'"].first[:hash]
    end

    def self.blocks_found
      filter(upstream_result: true, our_result: true).count
    end

    def self.by_username(username)
      filter(username: username).order(:created_at.desc)
    end

    def self.last_7d
      filter{ created_at > (Time.now - 7 * 24 * 60 * 60) }.
        group_and_count("date_trunc('hour', created_at)".lit).
        order(:date_trunc)
    end

    def self.last_24h
      _, _, h, d, m, y = Time.now.utc.to_a
      to = Time.utc(y, m, d, h)

      filter{ (created_at > (to - 24 * 60 * 60)) & (created_at < to) }.
        group_and_count("date_trunc('hour', created_at)".lit).
        order(:date_trunc)
    end

    def self.last_60m
      _, m, h, d, mo, y = Time.now.utc.to_a
      to = Time.utc(y, mo, d, h, m)

      filter{ (created_at > (to - 60 * 60)) & (created_at < to) }.
        group_and_count("date_trunc('minute', created_at)".lit).
        order(:date_trunc)
    end

    def self.current_shares
      DB["select distinct username,
           sum(case when reason is null then 0 else 1 end) as bad,
           sum(case when reason is null then 1 else 0 end) as good
         from shares 
         where created_at BETWEEN ? AND now()
         group by username
         order by good desc", last_block_time]
    end

    def self.won_shares
      filter(:our_result, :upstream_result)
    end

    def self.unpaid_winning_shares
      won_shares.filter(:paid => false)
    end

    def self.last_won_share(share=nil)
      if share
       won_shares.filter(["id < ?",share[:id]]).order(:created_at.desc).limit(1).first
      else
        won_shares.order(:created_at.asc).last
      end
    end

    def self.user_shares(winning_share, username)
      last = last_block(winning_share)
      filter(:username => username).
        filter("created_at BETWEEN #{last[:created_at]} AND #{winning_share[:created_at]}")
    end

    def self.won_shares_for(id)
      if this_block = DB[:shares].filter(:id => id).first
        if last = last_won_share(this_block)
          DB["select distinct username,
             sum(case when reason is null then 0 else 1 end) as bad,
             sum(case when reason is null then 1 else 0 end) as good
           from shares 
           where created_at BETWEEN ? AND ?
           group by username
           order by good desc", last[:created_at], this_block[:created_at] ]
        else
          raise "No last block for #{this_block}!"
        end
      else
        raise "Cannot find share with id of #{id}!"
      end
    end

    def self.total_shares_for_block(id)
      won_shares_for(id).inject(0) { |a,b| a + b[:good] }
    end

    def self.last_block_time
      share = filter(our_result: true, upstream_result: true).
        order(:created_at.desc).
        first
      share[:created_at] if share
    end

    def self.shares_by_block_by_user(name)
      blocks = filter(upstream_result: true, our_result: true).
        select(:created_at).order(:created_at.desc).map(&:created_at)
      blocks << Time.now

      blocks.each_cons(2){|to, from|
        yield from, to, filter(username: name, created_at: (from..to))
      }
    end

    def self.current_shares_by_username(username)
      DB["select distinct username, 
           sum(case when reason is null then 0 else 1 end) as bad,
           sum(case when reason is null then 1 else 0 end) as good
         from shares 
         where created_at BETWEEN ? AND now()
           and username = ?
         group by username
         order by username", last_block_time, username]
    end

    def to_block_header
      BlockHeader.new(solution[2..-1])
    end

    def to_json(*args)
      header = to_block_header
      {
        version: header.version,
        hash: header.block_hash,
        previous_block: header.previous_block,
        merkle_root: header.merkle_root,
        timestamp: header.timestamp,
        bits: header.bits,
        nonce: header.nonce,
        created_at: created_at.to_i,
        shares: self.class.total_shares_for_block(id),
      }.to_json(*args)
    end
  end
end
