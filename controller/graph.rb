module Namecoiner
  class Graph < Ramaze::Controller
    map '/graph'
    layout(:main){ !request.xhr? }

    provide(:json, engine: :None, type: 'application/json'){|a,o| o.to_json }

    def index
    end

    def last_24h
      filter = {}
      filter[:upstream_result] = to_bool(request[:u]) if request[:u]
      filter[:our_result] = to_bool(request[:o]) if request[:o]
      filter[:reason] = request[:r] if request[:r]

      last_24h_json(
        request[:label],
        Shares.last_24h.filter(filter)
      )
    end

    def last_60m
      filter = {}
      filter[:upstream_result] = to_bool(request[:u]) if request[:u]
      filter[:our_result] = to_bool(request[:o]) if request[:o]
      filter[:reason] = request[:r] if request[:r]

      last_60m_json(
        request[:label],
        Shares.last_60m.filter(filter)
      )
    end

    private

    def to_bool(str)
      case str
      when 'true'; true
      when 'false'; false
      end
    end

    def last_24h_json(label, dataset)
      { label: label,
        data: dataset.map{|slice|
          [slice[:date_trunc].utc.to_i * 1000, slice[:count]]
      }}
    end

    def last_60m_json(label, dataset)
      { label: label,
        data: dataset.map{|slice|
          [slice[:date_trunc].utc.to_i * 1000, slice[:count]]
      }}
    end
  end
end
