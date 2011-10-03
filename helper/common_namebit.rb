module Innate
  module Helper
    module CommonNamebit
      def details_current(username)
        # | Time started | Shares | Stales | Payout |
        @user_hash_per_sec = Namecoiner::Shares.ghash_per_sec_for(username)
        @user_ghash_per_sec = hashrate_format(@user_hash_per_sec)
        @current_start_time = Namecoiner::Shares.last_block_time
        @current_user_shares = Namecoiner::Shares.current_shares_by_username(username).first
        if @current_user_shares
          @current_user_good = @current_user_shares.fetch(:good, 0).to_i
          @current_user_bad = @current_user_shares.fetch(:bad, 0).to_i

          @current_shares = Namecoiner::Shares.current_shares
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

        @history = Namecoiner::Payout.filter(username: @username).order(:paid_at.desc)
        @total_loot = @history.all.inject(BigDecimal("0")){ |a,b| a + b[:amount] }
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
end
