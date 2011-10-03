module Namecoiner
  class ApiV1 < Ramaze::Controller
    map '/api1'
    provide(:json, engine: :None, type: 'application/json'){|a,o| o.to_json }
    helper :common_namebit

    def last_block
      {last_block: Shares.last_won_share}
    end

    def details(username)
      details_current(@username)

      result = {
        user: {
          total_loot: @total_loot.to_f
          current: {
            hash: @user_hash_per_sec,
            pretty_hash: @user_ghash_per_sec,
            shares: @current_user_shares,
            good_shares: @current_user_good,
            bad_shares: @current_user_bad,
            estimated_payment: @current_user_pay,
          },
          history: @history.map{|h|
            h.inspect
          },
        },
        namebit: {
          shares: @current_shares,
        }
      }
    end
  end
end
