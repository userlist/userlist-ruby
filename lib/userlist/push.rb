require 'userlist/push/client'
require 'userlist/push/strategies'

module Userlist
  class Push
    class << self
      [:event, :track, :user, :identify, :company].each do |method|
        define_method(method) { |*args| default_push_instance.send(method, *args) }
      end

    private

      def default_push_instance
        @default_push_instance ||= new
      end
    end

    def initialize(config = {})
      @config = Userlist.config.merge(config)
      @mutex = Mutex.new
    end

    def event(payload = {})
      with_mutex do
        raise ArgumentError, 'Missing required payload hash' unless payload
        raise ArgumentError, 'Missing required parameter :name' unless payload[:name]
        raise ArgumentError, 'Missing required parameter :user' unless payload[:user]

        payload[:occured_at] ||= Time.now

        strategy.call(:post, '/events', payload)
      end
    end
    alias track event

    def user(payload = {})
      with_mutex do
        raise ArgumentError, 'Missing required payload hash' unless payload
        raise ArgumentError, 'Missing required parameter :identifier' unless payload[:identifier]

        strategy.call(:post, '/users', payload)
      end
    end
    alias identify user

    def company(payload = {})
      with_mutex do
        raise ArgumentError, 'Missing required payload hash' unless payload
        raise ArgumentError, 'Missing required parameter :identifier' unless payload[:identifier]

        strategy.call(:post, '/companies', payload)
      end
    end

  private

    attr_reader :config

    def strategy
      @strategy ||= Userlist::Push::Strategies.strategy_for(config.push_strategy, config)
    end

    def with_mutex(&block)
      @mutex.synchronize(&block)
    end
  end
end
