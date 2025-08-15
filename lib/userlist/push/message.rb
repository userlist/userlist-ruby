module Userlist
  class Push
    class Message < Resource
      include Operations::Push

      has_one :user, type: 'Userlist::Push::User'
      has_one :company, type: 'Userlist::Push::Company'

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
