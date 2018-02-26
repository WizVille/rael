require 'data_tree'
require 'schema'
require 'ac_queue'
require 'operation'
require 'active_support/inflector'

module Rael
  class Importer
    def initialize(data_tree)
      @data_tree = data_tree
      @schema = data_tree.schema

      @data = data_tree.data

      @node_refs = {}
    end

    def import(origin)
      operations = self.get_operations(origin)

      ac_queue = Rael::AcQueue.new(:operations => operations)

      ac_queue.resolve
    end

    def get_operations(origin)
      operations = []

      if @data
        @data.each do |data|
          operations += self.resolve_schema(origin, @schema, data, :model_name => @data_tree.origin_model_name)
        end
      end

      binding.pry

      operations
    end

    def resolve_schema(
      ac_node,
      schema_node,
      data_node,
      operations = [],
      model_name:  nil,
      parent_model_name: nil,
      parent_node_id: nil
    )
      operation = self.resolve_node(
        ac_node,
        schema_node,
        data_node,
        :model_name => model_name,
        :parent_model_name => parent_model_name,
        :parent_node_id => parent_node_id
      )

      operations << operation

      if data_node[:foreign]
        data_node[:foreign].each do |foreign_key_name, foreign_data|
          case foreign_data
          when Array
            ac_sub_nodes = ac_node&.send(foreign_key_name)

            foreign_data.each_with_index do |_foreign_data, idx|
              ac_sub_node = ac_sub_nodes&.detect{ |ac_sub_node| ac_sub_node.id == _foreign_data[:id] }

              self.resolve_schema(
                ac_sub_node,
                schema_node[:foreign][foreign_key_name],
                _foreign_data,
                operations,
                :model_name => foreign_key_name.to_s.singularize,
                :parent_model_name => model_name,
                :parent_node_id => data_node[:node_id]
              )
            end
          else
            ac_sub_node = ac_node&.send(foreign_key_name)

            self.resolve_schema(
              ac_sub_node,
              schema_node[:foreign][foreign_key_name],
              foreign_data,
              operations,
              :model_name =>  foreign_key_name,
              :parent_model_name => model_name,
              :parent_node_id => data_node[:node_id]
            )
          end
        end
      end

      operations
    end

    def resolve_node(
      ac_node,
      schema_node,
      data_node,
      model_name:  nil,
      parent_model_name: nil,
      parent_node_id: nil
    )
      id = data_node[:id]

      operation_data = data_node.select { |key, value| [:static, :translated ].include?(key.to_sym) }
      operation = nil

      if schema_node&.dig(:options, :model_name)
        model_name = data_node[:options][:model_name]
      end

      if data_node[:ref]
        operation = Rael::Operation.new(
          :update,
          :model_name => model_name,
          :parent_model_name => parent_model_name,
          :parent_node_id => parent_node_id,
          :options => schema_node[:options],
          :ref => data_node[:ref]
        )
      else
        if ac_node
          operation = Rael::Operation.new(
            :update,
            :model_name => model_name,
            :parent_model_name => parent_model_name,
            :parent_node_id => parent_node_id,
            :node_id => data_node[:node_id],
            :model => ac_node,
            :data => operation_data,
            :options => schema_node[:options]
          )
        else
          operation = Rael::Operation.new(
            :create,
            :model_name => model_name,
            :parent_model_name => parent_model_name,
            :parent_node_id => parent_node_id,
            :node_id => data_node[:node_id],
            :data => operation_data,
            :options => schema_node[:options]
          )
        end
      end

      operation
    end
  end
end
