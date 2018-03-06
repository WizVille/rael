require 'active_support/inflector'
require 'carrierwave'

module Rael
  class Operation
    attr_reader :type, :model_name, :node_id, :model, :data, :ref, :options, :parent_model_name, :parent_node_id, :mutations

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
      @mutations = []
    end

    def resolve!(model_by_node_id)
      if self.type == :create
        @model = self.create_model(@model_name.to_s.classify)
      end

      if @ref
        @model = model_by_node_id[@ref.to_sym]
        @node_id = @ref.to_sym
      end

      self.set_static_attributes(model_by_node_id)
      self.set_translated_attributes(model_by_node_id)

      model_by_node_id[@node_id.to_sym] = @model
    end

    def revert!
      deleted_model = {}

      @mutations.each do |mutation|
        model = mutation[:model]

        unless model.destroyed?
          case mutation[:action]
          when :set_attr
            self.smart_set(model, mutation[:key], mutation[:old_val])
          when :set_translated_attrs
            model.attributes = mutation[:old_translation]
          when :save_model
            model.save
          when :create_model
            if model.respond_to?(:translations)
              model.translations.each(&:delete)
            end
            model.delete
          end
        end
      end

      @mutations = []
    end

    def create_model(model_name)
      model = model_name.constantize.new

      @mutations << {
        :action => :create_model,
        :model => model
      }

      model
    end

    def set_attribute(model, key, new_val)
      old_val = model[key]

      self.smart_set(model, key, new_val)

      @mutations << {
        :action => :set_attr,
        :model => model,
        :key => key,
        :old_val => old_val,
        :new_val => new_val
      }
    end

    def set_translation(model, translation)
      locale = translation[:locale].to_sym

      old_translation = model.translations.detect{|translation| translation.locale.to_sym == locale }&.attributes || {}
      old_translation = old_translation.select{|key, val| translation.keys.include?(key.to_sym) }

      model.attributes = translation

      @mutations << {
        :action => :set_translated_attrs,
        :model => model,
        :locale => locale,
        :old_translation => old_translation,
        :new_translation => translation
      }
    end

    def save_model(model)
      model.save!(:validate => false)

      @mutations << {
        :action => :save_model,
        :model => model
      }
    end

    def set_static_attributes(model_by_node_id)
      if @data[:static]
        @data[:static].each do |data_node_key, data_node_value|
          self.set_attribute(@model, data_node_key, data_node_value)
        end
      end

      if @parent_node_id
        if @options[:foreign_key_in_parent]
          self.save_model(@model)
          self.set_attribute(model_by_node_id[@parent_node_id.to_sym], @options[:foreign_key_name] || "#{@model_name}_id", @model.id)
          self.save_model(model_by_node_id[@parent_node_id.to_sym])
        else
          self.set_attribute(@model, @options[:foreign_key_name] || "#{@parent_model_name}_id", model_by_node_id[@parent_node_id.to_sym].id)
        end
      end

      self.save_model(@model)
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
          self.set_translation(@model, columns.merge({ :locale => locale }))
          self.save_model(@model)
        end
      end
    end

    def smart_set(model, key, val)
      if (model.send(key).kind_of?(CarrierWave::Uploader::Base) rescue false)
        begin
          file = open(val)

          extn = File.extname(val)
          name = File.basename(val, extn)
          content = File.open(file).read

          locale_file = Tempfile.open([name, extn]) do |f|
            f.write content
            f.flush
            model.send("#{key}=", f)
          end
        rescue
          # file does not exist anymore
        end
      else
        begin
          case val
          when Hash
            model[key] = val.with_indifferent_access
          else
            model[key] = val
          end
        rescue Exception => e
          raise Rael::Error.new("#{@model.class.table_name}.#{key}=#{val} failed: #{e.message}")
        end
      end
    end
  end
end
