module Userlist
  class Push
    class Company < Resource
      def self.endpoint
        '/companies'
      end

      def initialize(attributes = {}, config = Userlist.config)
        raise Userlist::ArgumentError, 'Missing required attributes hash' unless attributes
        raise Userlist::ArgumentError, 'Missing required parameter :identifier' unless attributes[:identifier]

        attributes[:relationships] &&= attributes[:relationships].map do |relationship|
          Relationship.from_payload(relationship, config, except: [:company])
        end

        super
      end
    end
  end
end
