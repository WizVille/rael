require 'operation'

module Rael
  class AcQueue
    def initialize(operations: [])
      @operations = operations
      @model_by_node_id = {}
    end

    def resolve
      @operations.each do |operation|
        operation.resolve!(@model_by_node_id)
      end
    end
  end
end
