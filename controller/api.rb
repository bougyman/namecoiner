module Namecoiner
  class ApiV1 < Ramaze::Controller
    map '/api1'
    provide(:json, engine: :None, type: 'application/json'){|a,o| o.to_json }

    def last_block
      {last_block: Shares.last_won_share}
    end
  end
end
