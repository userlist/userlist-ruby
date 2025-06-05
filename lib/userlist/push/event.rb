module Userlist
  class Push
    class Event < Resource
      include Operations::Push

      has_one :user, type: 'Userlist::Push::User'
      has_one :company, type: 'Userlist::Push::Company'

      def initialize(payload = {}, config = Userlist.config)
        raise Userlist::ArgumentError, 'Missing required payload' unless payload
        raise Userlist::ArgumentError, 'Missing required parameter :name' unless payload[:name]

        payload[:occurred_at] ||= payload[:occured_at] || Time.now

        super
      end

      def push?
        super && (user || company) && (user.nil? || user.push?) && (company.nil? || company.push?)
      end
    end
  end
end
