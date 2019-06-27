module Userlist
  class Push
    class Event < Resource
      def initialize(attributes = {})
        raise ArgumentError, 'Missing required attributes hash' unless attributes
        raise ArgumentError, 'Missing required parameter :name' unless attributes[:name]
        raise ArgumentError, 'Missing required parameter :user' unless attributes[:user]

        attributes[:occured_at] ||= Time.now

        super
      end
    end
  end
end
