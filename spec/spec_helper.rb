require "bundler/setup"
require "rael"
require "tuple"
require "exporter"
require "importer"
require "data_tree"
require "schema"
require "pry"
require 'date'
require 'json'
require 'active_record'

require_relative "./helpers/tuples.rb"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
