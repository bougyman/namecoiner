module Namecoiner
  NAMECOIN_CACHE = Dalli::Client.new

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
      Ramaze::Log.debug "Details for: #{@username}"
      session[:username] = @username

      details_current(@username)
      @history = Payout.filter(username: @username).order(:paid_at.desc)
      @total_loot = @history.all.inject(BigDecimal("0")) { |a,b| a + b[:amount] }
      Ramaze::Log.debug "Total Loot: #{@total_loot}"
    end

    def statistics
      last_block = NMC::Shares.last_won_share
      last_block_found = last_block.created_at.utc
      previous_block = NMC::Shares.last_won_share(last_block)
      previous_block_found = previous_block.created_at.utc
      @current_round_duration = "%02d:%02d" % Rational(Time.now.utc - last_block_found,60).divmod(60)
      @previous_round_duration = "%02d:%02d" % Rational(last_block_found - previous_block_found,60).divmod(60)
      @total_shares = NMC::Shares.count
      @average_time_per_round = "%02d:%02d" % NMC::Shares.average_time_per_round
      @average_shares_per_round = NMC::Shares.average_shares_per_round

      @stats = NAMECOIN_CACHE.get('namecoind_transactions')
      @stats.reject!{|stat|
        stat['amount'] < 49 || stat['amount'] > 51
      }
      Ramaze::Log.warn @stats.pretty_inspect
      @stats.compact.reverse!
    end

    def live_data
      NAMECOIN_CACHE.get('live_data')
    end

    private

    def details_current(username)
      # | Time started | Shares | Stales | Payout |
      @user_ghash_per_sec = hashrate_format(Shares.ghash_per_sec_for(username))
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
