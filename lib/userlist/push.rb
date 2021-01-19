require 'userlist/push/client'
require 'userlist/push/strategies'

require 'userlist/push/resource'
require 'userlist/push/resource_collection'
require 'userlist/push/relation'

require 'userlist/push/operations/create'
require 'userlist/push/operations/delete'

require 'userlist/push/user'
require 'userlist/push/company'
require 'userlist/push/relationship'
require 'userlist/push/event'

require 'userlist/push/serializer'

module Userlist
  class Push
    class << self
      [:event, :track, :user, :identify, :company, :users, :events, :companies, :relationships].each do |method|
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
      @events ||= Relation.new(self, Event, [Operations::Create])
    end

    def users
      @users ||= Relation.new(self, User, [Operations::Create, Operations::Delete])
    end

    def companies
      @companies ||= Relation.new(self, Company, [Operations::Create, Operations::Delete])
    end

    def relationships
      @relationships ||= Relation.new(self, Relationship, [Operations::Create, Operations::Delete])
    end

    def event(payload = {})
      events.create(payload)
    end

    def user(payload = {})
      users.create(payload)
    end

    def company(payload = {})
      companies.create(payload)
    end

    alias track event
    alias identify user
  end
end
