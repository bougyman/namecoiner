require_relative "../model/shares"

module Namecoiner
  class Payout < Sequel::Model
    set_dataset :payout
    many_to_one :share, :class => Shares, :key => :found_block
  end
end

