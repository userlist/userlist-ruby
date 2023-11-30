module Userlist
  class Push
    class Event < Resource
      include Operations::Create

      has_one :user, type: 'Userlist::Push::User'
      has_one :company, type: 'Userlist::Push::Company'

      def initialize(payload = {}, config = Userlist.config)
        raise Userlist::ArgumentError, 'Missing required payload' unless payload
        raise Userlist::ArgumentError, 'Missing required parameter :name' unless payload[:name]

        super
      end

      def occured_at
        payload[:occured_at] || Time.now
      end

      def push?
        super && (user.nil? || user.push?) && (company.nil? || company.push?)
      end
    end
  end
end
