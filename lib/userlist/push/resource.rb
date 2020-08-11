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

        def from_payload(payload)
          payload = { identifier: payload } if payload.is_a?(String)

          new(payload)
        end
      end

      attr_reader :attributes

      def initialize(attributes = {})
        @attributes = attributes
      end

      def respond_to_missing?(method, include_private = false)
        attribute = method.to_s.sub(/=$/, '')

        attributes.key?(attribute.to_sym) || super
      end

    private

      def method_missing(method, *args, &block)
        if method.to_s =~ /=$/
          attribute = method.to_s.sub(/=$/, '')
          attributes[attribute.to_sym] = args.first
        elsif attributes.key?(method.to_sym)
          attributes[method.to_sym]
        else
          super
        end
      end
    end
  end
end
