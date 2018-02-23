require "schema"

module Rael
  class Exporter
    def initialize(origin, schema)
      @origin = origin
      @schema = schema

      @obj_refs = {}

      Rael::Schema.new.valid_schema!(@origin, @schema)
    end

    def export
      return @result_tree if @result_tree

      @result_tree = []

      if @origin.is_a?(Array)
        @origin.each do |origin|
          @result_tree << self.resolve_schema(origin, @schema, {})
        end
      else
        @result_tree << self.resolve_schema(@origin, @schema, {})
      end

      @result_tree
    end

    def resolve_schema(ac_node, schema_node, output_tree)
      if ac_node
        if ac_node.is_a?(Array)
          ac_node.each do |_ac_node|
            output_tree << {}
            self.resolve_schema(_ac_node, schema_node, output_tree.last)
          end
        else
          # @obj_ref[ac_node.id] = output_tree

          self.resolve_node(ac_node, schema_node, output_tree)

          if schema_node[:foreign]
            schema_node[:foreign].each do |foreign_key_name, schema_node|
              ac_sub_node = ac_node.send(foreign_key_name)

              if ac_sub_node.is_a?(Array)
                if ac_sub_node.size > 0
                  output_tree[foreign_key_name] ||= []
                else
                  next
                end
              else
                if ac_sub_node
                  output_tree[foreign_key_name] ||= {}
                else
                  next
                end
              end

              self.resolve_schema(ac_sub_node, schema_node, output_tree[foreign_key_name])
            end
          end
        end
      end

      return output_tree
    end

    def resolve_node(ac_node, schema_node, output_tree)
      id = "#{ac_node.class.table_name} <#{ac_node.id}>".to_sym

      if schema_node[:options]
        output_tree[:options] = schema_node[:options]
      end

      if @obj_refs[id]
        output_tree[:ref] = id
      else
        output_tree[:id] = id

        if schema_node[:static]
          schema_node[:static].each do |schema_node_key|
            output_tree[:static] ||= {}
            output_tree[:static][schema_node_key] = ac_node.send(schema_node_key)
          end
        end

        if schema_node[:translated]
          schema_node[:translated].each do |translated_schema_node_key|
            ac_node.translations.each do |translation|
              locale = translation.locale

              output_tree[:translated] ||= {}
              output_tree[:translated][translated_schema_node_key] ||= {}
              output_tree[:translated][translated_schema_node_key][locale] = translation.send(translated_schema_node_key)
            end
          end
        end

        @obj_refs[id] = output_tree
      end
    end
  end
end
