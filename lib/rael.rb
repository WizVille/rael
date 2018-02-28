require "rael/version"
require "exporter"
require "importer"

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
end
