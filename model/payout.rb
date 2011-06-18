require_relative "../model/shares"

module Namecoiner
  class Payout < Sequel::Model
    set_dataset :payout
    many_to_one :share, :class => Shares, :key => :found_block

    def shares_of(username)
      max_time = share.created_at
      min_time = Shares.
        filter(["created_at < ?", max_time]).
        filter(our_result: true, upstream_result: true).
        order(:created_at.desc).first.created_at

      Shares.
        filter(["created_at < ?", max_time]).
        filter(["created_at > ?", min_time]).
        filter(username: username)
    end
  end
end

