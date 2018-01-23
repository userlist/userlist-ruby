require 'userlist/push/client'

module Userlist
  class Push
    def initialize(config = Userlist.config)
      @config = config
    end

    def event(payload = {})
      raise ArgumentError, 'Missing required parameter :name' unless payload && payload[:name]
      raise ArgumentError, 'Missing required parameter :user' unless payload && payload[:user]

      payload[:occured_at] ||= Time.now

      client.post('/events', payload)
    end

    def user(payload = {})
      raise ArgumentError, 'Missing required parameter :identifier' unless payload && payload[:identifier]

      client.post('/users', payload)
    end

    def company(payload = {})
      raise ArgumentError, 'Missing required parameter :identifier' unless payload && payload[:identifier]

      client.post('/companies', payload)
    end

  private

    attr_reader :config

    def client
      @client ||= Userlist::Push::Client.new(config)
    end
  end
end
