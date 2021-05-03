module Userlist
  class Push
    class ResourceCollection
      include Enumerable

      attr_reader :collection, :relationship, :owner, :config

      def initialize(collection, relationship, owner, config = Userlist.config)
        @collection = Array(collection)
        @relationship = relationship
        @owner = owner
        @config = config
      end

      def each
        collection.each do |resource|
          resource[inverse] = owner if inverse && resource.is_a?(Hash)

          yield type.from_payload(resource, config)
        end
      end

      def type
        Object.const_get(relationship[:type])
      end

      def inverse
        relationship[:inverse]
      end
    end
  end
end
