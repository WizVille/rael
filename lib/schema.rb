module Rael
  class Schema
    def valid_schema!(origin, schema)
      if origin.is_a?(Array)
        origin.each do |_origin|
          Rael::Schema.new.valid_tree!(_origin, schema)
        end
      else
        Rael::Schema.new.valid_tree!(origin, schema)
      end
    end

    def valid_tree!(ac_node, schema_node)
      if ac_node
        if ac_node.is_a?(Array)
          ac_node.each do |_ac_node|
            self.valid_tree!(_ac_node, schema_node)
          end
        else
          self.valid_model!(ac_node, schema_node)

          if schema_node[:foreign]
            schema_node[:foreign].each do |foreign_key_name, schema_node|
              self.valid_tree!(ac_node.send(foreign_key_name), schema_node)
            end
          end
        end
      end
    end

    def valid_model!(ac_model, schema_node)
      if schema_node[:static]
        ac_keys = ac_model&.attributes&.keys&.map(&:to_sym) || []
        schema_node[:static].each do |schema_node_key|
          if !ac_keys.include?(schema_node_key)
            raise "schema_node key #{schema_node_key} does not exit in model"
          end
        end
      end

      if schema_node[:translated]
        ac_keys = ac_model&.translations&.first&.attributes&.keys&.map(&:to_sym) || []
        schema_node[:translated].each do |translated_schema_node_key|
          if !ac_keys.include?(translated_schema_node_key)
            raise "Translated schema_node key #{schema_node_key} does not exit in model"
          end
        end
      end
    end
  end
end
