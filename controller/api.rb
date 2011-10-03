module Namecoiner
  class ApiV1 < Ramaze::Controller
    map '/api1'
    provide(:json, engine: :None, type: 'application/json'){|a,o| o.to_json }
    helper :common_namebit

    def last_block
      {last_block: Shares.last_won_share}
    end

    def details(username)
      details_current(username)

      history = @history.map do |payment|
        shares = payment.shares_of(username)
        {
          paid_at_ISO2822: payment.paid_at.utc.iso2822,
          percentage: payment.percentage.to_f,
          shares: shares.filter(reason: nil).count,
          stales: shares.filter(reason: 'stale').count,
          amount: payment.amount.to_f
        }
      end

      result = {
        user: {
          name: username,
          total_loot: @total_loot.to_f,
          current: {
            hash: @user_hash_per_sec,
            pretty_hash: @user_ghash_per_sec,
            good_shares: @current_user_good,
            bad_shares: @current_user_bad,
            estimated_payment: @current_user_pay.to_f,
          },
          history: history,
        },
      }
    end
  end
end
