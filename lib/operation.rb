require 'active_support/inflector'

module Rael
  class Operation
    attr_reader :type, :model_name, :node_id, :model, :data, :ref, :options, :resolved, :parent_model_name, :parent_node_id

    def initialize(
      type,
      model_name: nil,
      parent_model_name: nil,
      parent_node_id: nil,
      node_id: nil,
      model: nil,
      data: nil,
      ref: nil,
      options: nil
    )
      @type = type
      @model_name = model_name
      @parent_model_name = parent_model_name
      @parent_node_id = parent_node_id
      @node_id = node_id
      @model = model
      @data = data || {}
      @ref = ref
      @options = options || {}

      @resolved = false
    end

    def set_static_attributes(model_by_node_id)
      if @data[:static]
        @data[:static].each do |data_node_key, data_node_value|
          @model[data_node_key] = data_node_value
        end
      end

      if @parent_node_id
        if @options[:foreign_key_in_parent]
          @model.save!
          model_by_node_id[@parent_node_id.to_sym]["#{@model_name}_id"] = @model.id
          model_by_node_id[@parent_node_id.to_sym].save!
        else
          @model["#{@parent_model_name}_id"] = model_by_node_id[@parent_node_id.to_sym].id
        end
      end

      @model.save!
    end

    def set_translated_attributes(model_by_node_id)
      if @data[:translated]
        translated_hash = {}

        @data[:translated].each do |translated_data_key, translated_data|
          translated_data.each do |locale, column_val|
            translated_hash[locale] ||= {}
            translated_hash[locale][translated_data_key] = column_val
          end
        end

        translated_hash.each do |locale, columns|
          @model.attributes = columns.merge({ :locale => locale })

          @model.save!
        end
      end
    end

    def resolve!(model_by_node_id)
      if self.type == :create
        @model = @model_name.to_s.classify.constantize.new
      end

      if @ref
        @model = model_by_node_id[@ref.to_sym]
        @node_id = @ref.to_sym
      end

      self.set_static_attributes(model_by_node_id)
      self.set_translated_attributes(model_by_node_id)

      model_by_node_id[@node_id.to_sym] = @model

      @resolved = true
    end
  end
end
