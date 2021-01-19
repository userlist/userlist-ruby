module Userlist
  class Push
    class Relation
      def initialize(scope, type, operations = [])
        @scope = scope
        @type = type

        operations.each { |operation| singleton_class.send(:include, operation::ClassMethods) }
      end

      attr_reader :scope, :type

      def from_payload(payload, config = self.config)
        type.from_payload(payload, config)
      end

      def endpoint
        type.endpoint
      end

      def strategy
        scope.strategy
      end

      def config
        scope.config
      end
    end
  end
end
