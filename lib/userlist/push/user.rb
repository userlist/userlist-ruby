module Userlist
  class Push
    class User < Resource
      include Operations::Create
      include Operations::Delete

      has_many :relationships, type: 'Userlist::Push::Relationship', inverse: :user
      has_many :companies, type: 'Userlist::Push::Company'
      has_one  :company, type: 'Userlist::Push::Company'

      def initialize(payload = {}, config = Userlist.config)
        raise Userlist::ArgumentError, 'Missing required payload' unless payload
        raise Userlist::ArgumentError, 'Missing required parameter :identifier' unless payload[:identifier]

        super
      end
    end
  end
end
