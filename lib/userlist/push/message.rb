module Userlist
  class Push
    class Message < Resource
      include Operations::Create

      has_one :user, type: 'Userlist::Push::User'

      def initialize(payload = {}, config = Userlist.config)
        raise Userlist::ArgumentError, 'Missing required payload' unless payload

        super
      end

      def push?
        super && (user.nil? || user.push?)
      end
    end
  end
end
