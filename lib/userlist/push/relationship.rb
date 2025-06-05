module Userlist
  class Push
    class Relationship < Resource
      include Operations::Push
      include Operations::Delete

      has_one :user, type: 'Userlist::Push::User'
      has_one :company, type: 'Userlist::Push::Company'

      def push?
        super && user&.push? && company&.push?
      end
    end
  end
end
