module Namecoiner
  class Graph < Ramaze::Controller
    map '/graph'
    layout(:main){ !request.xhr? }

    provide(:json, engine: :None, type: 'application/json'){|a,o| o.to_json }

    def index
    end

    def last_7d
      json_out(Shares.last_7d)
    end

    def last_24h
      json_out(Shares.last_24h)
    end

    def last_60m
      json_out(Shares.last_60m)
    end

    private

    def to_bool(str)
      case str
      when 'true'; true
      when 'false'; false
      end
    end

    def json_out(dataset, label = request[:label])
      filter = {}
      filter[:upstream_result] = to_bool(request[:u]) if request[:u]
      filter[:our_result] = to_bool(request[:o]) if request[:o]
      filter[:reason] = request[:r] if request[:r]

      { label: label,
        data: dataset.filter(filter).map{|slice|
          [slice[:date_trunc].utc.to_i * 1000, slice[:count]]
      }}
    end
  end
end
