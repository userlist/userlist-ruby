module Userlist
  class Push
    class ResourceCollection
      include Enumerable

      attr_reader :collection, :type, :config

      def initialize(collection, type, config = Userlist.config)
        @collection = Array(collection)
        @type = type
        @config = config
      end

      def each
        collection.each do |resource|
          yield type.from_payload(resource, config)
        end
      end
    end
  end
end
