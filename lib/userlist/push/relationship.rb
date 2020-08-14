module Userlist
  class Push
    class Relationship < Resource
      def initialize(attributes = {}, config = Userlist.config)
        raise Userlist::ArgumentError, 'Missing required attributes hash' unless attributes
        raise Userlist::ArgumentError, 'Missing required parameter :user or :company' unless attributes[:user] || attributes[:company]

        attributes[:user] &&= Userlist::Push::User.from_payload(attributes[:user], config, except: [:relationships])
        attributes[:company] &&= Userlist::Push::Company.from_payload(attributes[:company], config, except: [:relationships])

        super
      end

      def url
        raise Userlist::Error, "Cannot generate url for #{self.class.name} without a user" unless user
        raise Userlist::Error, "Cannot generate url for #{self.class.name} without a company" unless company

        "#{self.class.endpoint}/#{user.identifier}/#{company.identifier}"
      end
    end
  end
end
