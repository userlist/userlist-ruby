module Userlist
  class Push
    class Company < Resource
      def self.endpoint
        '/companies'
      end

      def initialize(attributes = {})
        raise ArgumentError, 'Missing required attributes hash' unless attributes
        raise ArgumentError, 'Missing required parameter :identifier' unless attributes[:identifier]

        super
      end
    end
  end
end
