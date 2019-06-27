module Userlist
  class Push
    class User < Resource
      def initialize(attributes = {})
        raise ArgumentError, 'Missing required attributes hash' unless attributes
        raise ArgumentError, 'Missing required parameter :identifier' unless attributes[:identifier]

        super
      end
    end
  end
end
