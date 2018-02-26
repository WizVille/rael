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
      @data = data
      @ref = ref
      @options = options

      @resolved = false
    end

    def resolve!
      if self.type == :create
        @model = @model_name.classify.constantize.new
      end

      if @data[:static]
        @data[:static].each do |data_node_key, data_node_value|
          @model[data_node_key] = data_node_value
        end

        if @parent_model_name
           @model["#{@parent_model_name}_id"] = self.parent_node_id
        end

        @model.save!
      end

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

      @resolved = true
    end
  end
end
