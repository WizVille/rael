require 'rael/data_tree'
require 'rael/schema'

module Rael
  class Exporter
    def initialize(origin, schema)
      @origin = origin
      @schema = schema

      @schema_tree = @schema.schema_tree

      @obj_refs = {}
    end

    def export
      return @data_tree if @data_tree

      @data_tree = DataTree.new(@schema.origin_model_name, :schema => @schema_tree)

      if @origin.is_a?(Array)
        @origin.each do |origin|
          @data_tree.push_data(self.resolve_schema(origin, @schema_tree, {}))
        end
      else
        @data_tree.push_data(self.resolve_schema(@origin, @schema_tree, {}))
      end

      @data_tree
    end

    def resolve_schema(ac_node, schema_node, output_tree)
      if ac_node
        if self.kind_of_array?(ac_node)
          ac_node.each do |_ac_node|
            output_tree << {}
            self.resolve_schema(_ac_node, schema_node, output_tree.last)
          end
        else
          self.resolve_node(ac_node, schema_node, output_tree)

          if schema_node[:foreign]
            schema_node[:foreign].each do |foreign_key_name, schema_node|
              begin
                ac_sub_node = ac_node.send(foreign_key_name)
              rescue
                raise "Invalid foreign key <#{foreign_key_name}> in model <#{ac_node.class.table_name}>"
              end

              if self.kind_of_array?(ac_sub_node)
                if ac_sub_node.size > 0
                  output_tree[:foreign] ||= {}
                  output_tree[:foreign][foreign_key_name] ||= []
                else
                  next
                end
              else
                if ac_sub_node
                  output_tree[:foreign] ||= {}
                  output_tree[:foreign][foreign_key_name] ||= {}
                else
                  next
                end
              end

              self.resolve_schema(ac_sub_node, schema_node, output_tree[:foreign][foreign_key_name])
            end
          end
        end
      end

      return output_tree
    end

    def kind_of_array?(instance)
      instance.respond_to?(:compact)
    end

    def resolve_node(ac_node, schema_node, output_tree)
      Rael::Schema.validate_model!(ac_node, schema_node)

      node_id = "#{ac_node.class.table_name} <#{ac_node.id}>".to_sym

      if schema_node[:options]
        output_tree[:options] = schema_node[:options]
      end

      if @obj_refs[node_id]
        output_tree[:ref] = node_id
      else
        output_tree[:id] = ac_node.id
        output_tree[:node_id] = node_id

        if schema_node[:static]
          schema_node[:static].each do |schema_node_key|
            output_tree[:static] ||= {}
            output_tree[:static][schema_node_key] = ac_node[schema_node_key]
          end
        end

        if schema_node[:translated]
          schema_node[:translated].each do |translated_schema_node_key|
            ac_node.translations.each do |translation|
              locale = translation.locale

              output_tree[:translated] ||= {}
              output_tree[:translated][translated_schema_node_key] ||= {}
              output_tree[:translated][translated_schema_node_key][locale] = translation[translated_schema_node_key]
            end
          end
        end

        @obj_refs[node_id] = output_tree
      end
    end
  end
end
