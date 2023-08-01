module Userlist
  class Push
    module Strategies
      def self.strategy_for(strategy, config = {})
        strategy = lookup_strategy(strategy)
        strategy = strategy.new(config) if strategy.respond_to?(:new)

        strategy
      end

      def self.lookup_strategy(strategy)
        return strategy unless strategy.is_a?(Symbol) || strategy.is_a?(String)

        require_strategy(strategy)

        class_name = classify_strategy(strategy)
        const_get(class_name, false)
      end

      def self.strategy_defined?(strategy)
        return true unless strategy.is_a?(Symbol) || strategy.is_a?(String)

        class_name = classify_strategy(strategy)
        const_defined?(class_name, false)
      end

      def self.require_strategy(strategy)
        return unless strategy.is_a?(Symbol) || strategy.is_a?(String)

        require("userlist/push/strategies/#{strategy}") unless strategy_defined?(strategy)
      end

      def self.classify_strategy(strategy)
        strategy.to_s.split('_').map(&:capitalize).join
      end
      private_class_method :classify_strategy
    end
  end
end
