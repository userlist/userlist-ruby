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
        const_get(strategy.to_s.capitalize, false)
      end

      def self.strategy_defined?(strategy)
        return true unless strategy.is_a?(Symbol) || strategy.is_a?(String)

        const_defined?(strategy.to_s.capitalize, false)
      end

      def self.require_strategy(strategy)
        return unless strategy.is_a?(Symbol) || strategy.is_a?(String)

        require("userlist/push/strategies/#{strategy}") unless strategy_defined?(strategy)
      end
    end
  end
end
