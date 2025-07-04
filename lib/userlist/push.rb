require 'userlist/push/client'
require 'userlist/push/strategies'

require 'userlist/push/resource'
require 'userlist/push/resource_collection'
require 'userlist/push/relation'

require 'userlist/push/operations/push'
require 'userlist/push/operations/delete'

require 'userlist/push/user'
require 'userlist/push/company'
require 'userlist/push/relationship'
require 'userlist/push/event'
require 'userlist/push/message'

require 'userlist/push/serializer'

module Userlist
  class Push
    class << self
      [:event, :track, :user, :identify, :company, :message, :users, :events, :companies, :relationships, :messages].each do |method|
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

    attr_reader :config, :strategy

    def events
      @events ||= Relation.new(self, Event, [Operations::Push])
    end

    def users
      @users ||= Relation.new(self, User, [Operations::Push, Operations::Delete])
    end

    def companies
      @companies ||= Relation.new(self, Company, [Operations::Push, Operations::Delete])
    end

    def relationships
      @relationships ||= Relation.new(self, Relationship, [Operations::Push, Operations::Delete])
    end

    def messages
      @messages ||= Relation.new(self, Message, [Operations::Push])
    end

    def event(payload = {})
      events.push(payload)
    end

    def user(payload = {})
      users.push(payload)
    end

    def company(payload = {})
      companies.push(payload)
    end

    def message(payload = {})
      messages.push(payload)
    end

    alias track event
    alias identify user
  end
end
