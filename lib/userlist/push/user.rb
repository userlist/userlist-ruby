module Userlist
  class Push
    class User < Resource
      def self.defaults
        {
          relationships: []
        }
      end

      def initialize(attributes = {}, config = Userlist.config)
        raise Userlist::ArgumentError, 'Missing required attributes hash' unless attributes
        raise Userlist::ArgumentError, 'Missing required parameter :identifier' unless attributes[:identifier]

        attributes[:relationships] &&= attributes[:relationships].map do |relationship|
          Relationship.from_payload(relationship, config, except: [:user])
        end

        super
      end
    end
  end
end
