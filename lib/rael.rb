require "rael/version"
require "exporter"
require "importer"
require "schema"

module Rael
  def self.clone(origin, schema, destination)
    Rael::Importer.new(
      Rael::Exporter.new(origin, schema).export.serialize
    ).import(destination)
  end

  def self.export(origin, schema)
    Rael::Exporter.new(origin, schema).export.serialize
  end

  def self.import(data_tree, destination)
    Rael::Importer.new(data_tree).import(destination)
  end

  def self.schema(origin_model_name, schema_tree)
    Rael::Schema.new(origin_model_name, schema_tree)
  end
end
