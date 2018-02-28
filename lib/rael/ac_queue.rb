require 'rael/operation'

module Rael
  class AcQueue
    def initialize(operations: [])
      @operations = operations
      @model_by_node_id = {}
    end

    def resolve
      begin
        @operations.each do |operation|
          operation.resolve!(@model_by_node_id)
        end
      rescue Exception => e
        @operations.each do |operation|
          operation.revert!
        end

        raise Rael::Error.new(e)
      end
    end
  end
end
