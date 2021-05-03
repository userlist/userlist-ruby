module Userlist
  class Push
    class Company < Resource
      include Operations::Create
      include Operations::Delete

      def self.endpoint
        '/companies'
      end

      has_many :relationships, type: 'Userlist::Push::Relationship', inverse: :company
      has_many :users, type: 'Userlist::Push::User'
      has_one  :user, type: 'Userlist::Push::User'

      def initialize(payload = {}, config = Userlist.config)
        raise Userlist::ArgumentError, 'Missing required payload hash' unless payload
        raise Userlist::ArgumentError, 'Missing required parameter :identifier' unless payload[:identifier]

        super
      end
    end
  end
end
