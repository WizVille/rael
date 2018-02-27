module Rael
  class Schema
    attr_reader :schema_tree, :origin_model_name

    def initialize(origin_model_name, schema_tree)
      @schema_tree = schema_tree
      @origin_model_name = origin_model_name
    end

    def self.validate_model!(ac_model, schema_node)
      if schema_node[:static]
        ac_keys = ac_model&.attributes&.keys&.map(&:to_sym) || []
        schema_node[:static].each do |schema_node_key|
          if !ac_keys.include?(schema_node_key)
            raise "schema_node key <#{schema_node_key}> does not exit in model <#{ac_model.class.table_name}>"
          end
        end
      end

      if schema_node[:translated]
        ac_keys = ac_model&.translations&.first&.attributes&.keys&.map(&:to_sym) || []
        schema_node[:translated].each do |translated_schema_node_key|
          if !ac_keys.include?(translated_schema_node_key)
            raise "Translated schema_node key <#{schema_node_key}> does not exit in model <#{ac_model.class.table_name}>"
          end
        end
      end
    end
  end
end
