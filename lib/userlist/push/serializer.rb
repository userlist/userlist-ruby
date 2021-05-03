require 'set'

module Userlist
  class Push
    class Serializer
      def self.serialize(resource)
        new.serialize(resource)
      end

      def serialize(resource)
        resource = serialize_resource(resource) if resource.is_a?(Userlist::Push::Resource)
        resource
      end

    private

      def serialize_resource(resource)
        return resource.identifier if serialized_resources.include?(resource)

        serialized_resources << resource

        return unless resource.push?

        serialized = {}

        resource.attribute_names.each do |name|
          serialized[name] = resource.send(name)
        end

        resource.relationship_names.each do |name|
          next unless result = serialize_relationship(resource.send(name))

          serialized[name] = result
        end

        serialized
      end

      def serialize_relationship(relationship)
        return unless relationship

        case relationship
        when Userlist::Push::ResourceCollection
          serialize_collection(relationship)
        when Userlist::Push::Resource
          serialize_resource(relationship)
        else
          raise "Cannot serialize relationship type: #{relationship.class}"
        end
      end

      def serialize_collection(collection)
        serialized = collection
          .map(&method(:serialize_relationship))
          .compact
          .reject(&:empty?)

        serialized unless serialized.empty?
      end

      def serialized_resources
        @serialized_resources ||= Set.new
      end
    end
  end
end
