require 'rael/error'

module Rael
  class Schema
    attr_reader :schema_tree, :origin_model_name

    def initialize(origin_model_name, schema_tree)
      @schema_tree = schema_tree
      @origin_model_name = origin_model_name
    end

    def self.validate_model!(ac_model, schema_node)
      if Rael::Schema.static(schema_node).size > 0
        ac_keys = ac_model&.attributes&.keys&.map(&:to_sym) || []
        Rael::Schema.static(schema_node).each do |schema_node_key|
          if !ac_keys.include?(schema_node_key)
            raise Rael::Error.new("Key <#{schema_node_key}> does not exit in model <#{ac_model.class.table_name}>")
          end
        end
      end

      if Rael::Schema.translated(schema_node).size > 0
        ac_keys = ac_model&.class&.translated_attribute_names || []

        Rael::Schema.translated(schema_node).each do |translated_schema_node_key|
          if !ac_keys.include?(translated_schema_node_key)
            raise Rael::Error.new("Translated key <#{translated_schema_node_key}> does not exit in model <#{ac_model.class.table_name}>")
          end
        end
      end
    end

    def self.static(schema_node)
      schema_node[:s] || schema_node[:static] || []
    end

    def self.translated(schema_node)
      schema_node[:t] || schema_node[:translated] || []
    end

    def self.foreign(schema_node)
      schema_node[:f] || schema_node[:foreign] || {}
    end

    def self.options(schema_node)
      schema_node[:o] || schema_node[:options] || {}
    end
  end
end
