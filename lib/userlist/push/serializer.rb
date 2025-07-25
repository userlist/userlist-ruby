require 'set'

module Userlist
  class Push
    class Serializer
      def self.serialize(resource, **options)
        new(**options).serialize(resource)
      end

      attr_reader :context

      def initialize(context:)
        @context = context
      end

      def serialize(resource)
        resource = serialize_resource(resource) if resource.is_a?(Userlist::Push::Resource)
        resource
      end

      def serialize?(resource)
        method_name = "#{context}?"

        resource.respond_to?(method_name) &&
          resource.public_send(method_name)
      end

    private

      def serialize_resource(resource)
        return resource.identifier if serialized_resources.include?(resource)

        serialized_resources << resource

        return unless serialize?(resource)

        serialized = {}

        resource.attribute_names.each do |name|
          serialized[name] = resource.send(name)
        end

        resource.association_names.each do |name|
          next unless result = serialize_association(resource.send(name))

          serialized[name] = result
        end

        serialized
      end

      def serialize_association(association)
        return unless association

        case association
        when Userlist::Push::ResourceCollection
          serialize_collection(association)
        when Userlist::Push::Resource
          serialize_resource(association)
        else
          raise "Cannot serialize association type: #{association.class}"
        end
      end

      def serialize_collection(collection)
        serialized = collection
          .map(&method(:serialize_association))
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
