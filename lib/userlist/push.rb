require 'userlist/push/client'
require 'userlist/push/strategies'

module Userlist
  class Push
    def initialize(config = {})
      @config = Userlist.config.merge(config)
    end

    def event(payload = {})
      raise ArgumentError, 'Missing required payload hash' unless payload
      raise ArgumentError, 'Missing required parameter :name' unless payload[:name]
      raise ArgumentError, 'Missing required parameter :user' unless payload[:user]

      payload[:occured_at] ||= Time.now

      strategy.call(:post, '/events', payload)
    end

    def user(payload = {})
      raise ArgumentError, 'Missing required payload hash' unless payload
      raise ArgumentError, 'Missing required parameter :identifier' unless payload[:identifier]

      strategy.call(:post, '/users', payload)
    end

    def company(payload = {})
      raise ArgumentError, 'Missing required payload hash' unless payload
      raise ArgumentError, 'Missing required parameter :identifier' unless payload[:identifier]

      strategy.call(:post, '/companies', payload)
    end

  private

    attr_reader :config

    def strategy
      @strategy ||= Userlist::Push::Strategies.strategy_for(config.push_strategy, config)
    end
  end
end
