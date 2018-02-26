require 'operation'

module Rael
  class AcQueue
    def initialize(operations: [])
      @operations = operations
    end

    def resolve
      @operations.each do |operation|
        case operation.type
        when :create
          operation.resolve!
        when :update
          operation.resolve!
        end
      end
    end
  end
end
