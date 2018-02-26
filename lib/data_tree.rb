module Rael
  class DataTree
    attr_reader :data, :schema, :origin_model_name

    def initialize(origin_model_name, schema: {}, data: [])
      @origin_model_name = origin_model_name
      @schema = schema
      @data = data
    end

    def push_data(data)
      @data << data
    end

    def data
      self.symbolize_keys(@data)
    end

    def schema
      self.symbolize_keys(@schema)
    end

    def symbolize_keys(node)
      case node
      when Array
        node.each_with_index do |_node, idx|
          node[idx] = symbolize_keys(_node)
        end
      when Hash
        node = node.inject({}){ |memo,(k,v)| memo[k.to_sym] = v; memo}
        node.each { |k, v| node[k] = self.symbolize_keys(v) }
        node
      else
        node
      end
    end
  end
end
