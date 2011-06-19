module Namecoiner
  class Main < Ramaze::Controller
    map '/'
    layout(:main){ !request.xhr? }
    provide(:json, engine: :None, type: 'application/json'){|a,o| o.to_json }

    def index
      live_data.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def my_account
      @username = session[:username]
    end

    def details(username = nil)
      @username = (username || request[:username]).to_s.strip
      session[:username] = @username

      details_current(@username)
      @history = Payout.filter(username: @username).order(:paid_at.desc)
    end

    def statistics
      @stats = JSON.parse(`~/bin/namecoind listtransactions "" 10000`)
      @stats.reject!{|stat|
        stat['amount'] < 49 || stat['amount'] > 51
      }
      @stats.reverse!
    end

    def live_data
      hashrate = Shares.hash_per_second
      blocks_found = Shares.blocks_found
      current_share_count = NMC::Shares.current_shares.inject(0) { |total,share| share[:good] + total }
      blocks_total = `~/bin/namecoind getblockcount`.to_i
      difficulty = `~/bin/namecoind getdifficulty`.to_f

      { hashrate: hashrate_format(hashrate),
        blocks_found: blocks_found,
        blocks_total: blocks_total,
        difficulty: "%.2f" % difficulty,
        current_share_count: current_share_count
      }
    end

    private

    def details_current(username)
      # | Time started | Shares | Stales | Payout |
      @current_start_time = Shares.last_block_time
      @current_user_shares = Shares.current_shares_by_username(username).first
      if @current_user_shares
        @current_user_good = @current_user_shares.fetch(:good, 0).to_i
        @current_user_bad = @current_user_shares.fetch(:bad, 0).to_i

        @current_shares = Shares.current_shares
        all_shares = @current_shares.inject 0 do |s,v|
          s + v[:good].to_i
        end
        @current_user_pay =
          Rational(49, all_shares) * @current_user_good
      else
        @current_user_good = 0
        @current_user_bad = 0
        @current_user_pay = 0
      end
    end

    HASHRATE_FORMAT = [
      ['%.2fTih/s', 1_000_000_000_000],
      ['%.2fGih/s', 1_000_000_000],
      ['%.2fMih/s', 1_000_000],
      ['%.2fKih/s', 1_000],
    ]

    def hashrate_format(hashrate)
      HASHRATE_FORMAT.each do |format, size|
        return format % (hashrate.to_f / size) if hashrate >= size
      end

      "%.2fh/s" % hashrate.to_f
    end
  end
end
