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

        def from_payload(payload, config = Userlist.config, options = {})
          payload = { identifier: payload } if payload.is_a?(String)

          keys =
            if options[:only]
              Array(options[:only])
            elsif options[:except]
              payload.keys - Array(options[:except])
            else
              payload.keys
            end

          new(payload.slice(*keys), config)
        end
      end

      attr_reader :attributes, :config

      def initialize(attributes = {}, config = Userlist.config)
        @attributes = attributes
        @config = config
      end

      def respond_to_missing?(method, include_private = false)
        attribute = method.to_s.sub(/=$/, '')

        attributes.key?(attribute.to_sym) || super
      end

      def to_hash
        attributes
      end
      alias to_h to_hash

      def url
        "#{self.class.endpoint}/#{identifier}"
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
