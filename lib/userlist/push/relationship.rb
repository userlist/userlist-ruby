module Userlist
  class Push
    class Relationship < Resource
      include Operations::Create
      include Operations::Delete

      has_one :user, type: 'Userlist::Push::User'
      has_one :company, type: 'Userlist::Push::Company'

      def url
        raise Userlist::Error, "Cannot generate url for #{self.class.name} without a user" unless user
        raise Userlist::Error, "Cannot generate url for #{self.class.name} without a company" unless company

        "#{self.class.endpoint}/#{user.identifier}/#{company.identifier}"
      end

      def push?
        super && user&.push? && company&.push?
      end
    end
  end
end
