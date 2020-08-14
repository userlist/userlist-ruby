module Userlist
  class Push
    class Event < Resource
      def initialize(attributes = {}, config = Userlist.config)
        raise Userlist::ArgumentError, 'Missing required attributes hash' unless attributes
        raise Userlist::ArgumentError, 'Missing required parameter :name' unless attributes[:name]
        raise Userlist::ArgumentError, 'Missing required parameter :user or :company' unless attributes[:user] || attributes[:company]

        attributes[:user] &&= Userlist::Push::User.from_payload(attributes[:user], config)
        attributes[:company] &&= Userlist::Push::Company.from_payload(attributes[:company], config)
        attributes[:occured_at] ||= Time.now

        super
      end
    end
  end
end
