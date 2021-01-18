module Userlist
  class Push
    class Resource
      class << self
        def resource_name
          name.split('::')[-1]
        end

        def endpoint
          "/#{resource_name.downcase}s"
        end

        def from_payload(payload, config = Userlist.config)
          return payload if payload.nil?
          return payload if payload.is_a?(self)

          payload = { identifier: payload } if payload.is_a?(String)

          new(payload, config)
        end

        def relationship_names
          @relationship_names ||= Set.new
        end

      protected

        def has_one(name, type:)
          relationship_names << name.to_sym

          generated_methods.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{name}
              #{type}.from_payload(payload[:#{name}], config)
            end
          RUBY
        end

        def has_many(name, type:)
          relationship_names << name.to_sym

          generated_methods.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{name}
              ResourceCollection.new(payload[:#{name}], #{type}, config)
            end
          RUBY
        end

      private

        def generated_methods
          @generated_methods ||= Module.new.tap { |mod| include mod }
        end
      end

      attr_reader :payload, :config

      def initialize(payload = {}, config = Userlist.config)
        @payload = payload
        @config = config
      end

      def respond_to_missing?(method, include_private = false)
        attribute = method.to_s.sub(/=$/, '')
        payload.key?(attribute.to_sym) || super
      end

      def to_hash
        Serializer.serialize(self)
      end
      alias to_h to_hash

      def to_json(*args)
        to_hash.to_json(*args)
      end

      def url
        "#{self.class.endpoint}/#{identifier}"
      end

      def identifier
        payload[:identifier]
      end

      def hash
        self.class.hash & payload.hash
      end

      def eql?(other)
        self.hash == other.hash
      end

      def ==(other)
        self.hash == other.hash
      end

      def attribute_names
        payload.keys.map(&:to_sym) - relationship_names
      end

      def relationship_names
        self.class.relationship_names.to_a
      end

      def push?
        true
      end

    private

      def method_missing(method, *args, &block)
        if method.to_s =~ /=$/
          attribute = method.to_s.sub(/=$/, '')
          payload[attribute.to_sym] = args.first
        elsif payload.key?(method.to_sym)
          payload[method.to_sym]
        else
          super
        end
      end
    end
  end
end
