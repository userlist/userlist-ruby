require 'userlist/push/client'
require 'userlist/push/strategies'

require 'userlist/push/resource'
require 'userlist/push/user'
require 'userlist/push/company'
require 'userlist/push/event'
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

    def initialize(configuration = {})
      @config = Userlist.config.merge(configuration)
      @strategy = Userlist::Push::Strategies.strategy_for(config.push_strategy, config)
    end

    def event(payload = {})
      raise ArgumentError, 'Missing required payload hash' unless payload
      raise ArgumentError, 'Missing required parameter :name' unless payload[:name]
      raise ArgumentError, 'Missing required parameter :user' unless payload[:user]

      payload[:occured_at] ||= Time.now

      strategy.call(:post, '/events', payload)
    end
    alias track event

    def user(payload = {})
      raise ArgumentError, 'Missing required payload hash' unless payload
      raise ArgumentError, 'Missing required parameter :identifier' unless payload[:identifier]

      strategy.call(:post, '/users', payload)
    end
    alias identify user

    def company(payload = {})
      raise ArgumentError, 'Missing required payload hash' unless payload
      raise ArgumentError, 'Missing required parameter :identifier' unless payload[:identifier]

      strategy.call(:post, '/companies', payload)
    end

  private

    attr_reader :config, :strategy
  end
end
