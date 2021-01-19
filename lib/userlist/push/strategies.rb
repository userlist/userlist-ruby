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

        name = strategy.to_s.capitalize
        require("userlist/push/strategies/#{name}") unless const_defined?(name, false)
        const_get(name, false)
      end
    end
  end
end
