require 'set'

module Userlist
  class Push
    class Serializer
      def self.serialize(resource, **options)
        new(**options).serialize(resource)
      end

      attr_reader :context

      def initialize(context:, include: nil)
        @context = context
        @include = normalize_include_options(include)
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
        return serialize_identifier(resource) if serialized?(resource)

        serialized_resources << resource

        return unless serialize?(resource)

        serialized = {}

        resource.attribute_names.each do |name|
          serialized[name] = serialize_attribute(resource, name)
        end

        resource.association_names.each do |name|
          next unless result = serialize_association(resource, name)

          serialized[name] = result
        end

        serialized
      end

      def serialize_attribute(resource, name)
        resource.send(name)
      end

      def serialize_association(resource, name)
        return unless association = resource.send(name)
        return serialize_identifier(association) unless include?(name)

        with_include_for(name) do
          case association
          when Userlist::Push::ResourceCollection
            serialize_collection(association)
          when Userlist::Push::Resource
            serialize_resource(association)
          else
            raise "Cannot serialize association type: #{association.class}"
          end
        end
      end

      def serialize_identifier(resource)
        case resource
        when Userlist::Push::Resource
          resource.identifier
        end
      end

      def serialize_collection(collection)
        serialized = collection
          .map(&method(:serialize_resource))
          .compact
          .reject(&:empty?)

        serialized unless serialized.empty?
      end

      def serialized_resources
        @serialized_resources ||= Set.new
      end

      def serialized?(resource)
        serialized_resources.include?(resource)
      end

      def include?(name)
        @include.nil? || @include.fetch(name.to_sym, false)
      end

      def with_include_for(name)
        original_include = @include
        @include = @include&.fetch(name.to_sym, false)

        yield
      ensure
        @include = original_include
      end

      def normalize_include_options(value)
        case value
        when Array
          value.inject({}) { |acc, v| acc.merge(normalize_include_options(v)) }
        when Hash
          value.to_h { |k, v| [k.to_sym, normalize_include_options(v)] }
        when Symbol, String
          { value.to_sym => {} }
        when false
          {}
        end
      end
    end
  end
end
