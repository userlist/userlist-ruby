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
    end
  end
end
