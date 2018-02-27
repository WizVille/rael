require "rael/version"
require "exporter"
require "importer"

module Rael
  def self.export(origin, schema)
    Rael::Exporter.new(origin, schema).export.serialize
  end

  def self.import(data_tree, origin)
    Rael::Importer.new(data_tree).import(origin)
  end
end
