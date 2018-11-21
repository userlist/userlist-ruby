require 'userlist/push/strategies/null'
require 'userlist/push/strategies/direct'
require 'userlist/push/strategies/threaded'

module Userlist
  class Push
    module Strategies
      def self.strategy_for(strategy, config = {})
        strategy = Userlist::Push::Strategies.const_get(strategy.to_s.capitalize) if strategy.is_a?(Symbol) || strategy.is_a?(String)

        strategy = strategy.new(config) if strategy.respond_to?(:new)

        strategy
      end
    end
  end
end
