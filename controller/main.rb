module Namecoiner
  NAMECOIN_CACHE = Dalli::Client.new

  class Main < Ramaze::Controller
    map '/'
    layout(:main){ !request.xhr? }
    provide(:json, engine: :None, type: 'application/json'){|a,o| o.to_json }
    helper :common_namebit

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
    end

    def statistics
      @last_block_found = NAMECOIN_CACHE.get('last_block_found')
      @current_round_duration = NAMECOIN_CACHE.get('current_round_duration')
      @previous_round_duration = NAMECOIN_CACHE.get('previous_round_duration')
      @total_shares = NAMECOIN_CACHE.get('total_shares')
      @average_time_per_round = NAMECOIN_CACHE.get('average_time_per_round')
      @average_shares_per_round = NAMECOIN_CACHE.get('average_shares_per_round')

      @stats = NAMECOIN_CACHE.get('namecoind_transactions')
      @stats.reject!{|stat| stat['amount'] < 49 || stat['amount'] > 51 }
      @stats.compact.reverse!
    end

    def live_data
      NAMECOIN_CACHE.get('live_data')
    end
  end
end
