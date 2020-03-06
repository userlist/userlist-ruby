module Userlist
  class Push
    class User < Resource
      def initialize(attributes = {})
        raise Userlist::ArgumentError, 'Missing required attributes hash' unless attributes
        raise Userlist::ArgumentError, 'Missing required parameter :identifier' unless attributes[:identifier]

        super
      end
    end
  end
end
