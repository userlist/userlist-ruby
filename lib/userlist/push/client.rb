require 'uri'
require 'json'
require 'net/http'
require 'openssl'

module Userlist
  class Push
    class Client
      include Userlist::Logging

      def initialize(config = Userlist.config)
        @config = config
      end

      def post(endpoint, payload = {})
        request(endpoint, payload)
      end

    private

      attr_reader :config

      def http
        @http ||= begin
          http = Net::HTTP.new(endpoint.host, endpoint.port)

          if endpoint.scheme == 'https'
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          end

          http
        end
      end

      def request(path, payload = {})
        request = Net::HTTP::Post.new(path)
        request['Accept'] = 'application/json'
        request['Authorization'] = "Push #{token}"
        request['Content-Type'] = 'application/json; charset=UTF-8'
        request.body = JSON.dump(payload)

        logger.debug "Sending #{request.method} to #{URI.join(endpoint, request.path)} with body #{request.body}"

        http.request(request)
      end

      def endpoint
        @endpoint ||= URI(config.push_endpoint)
      end

      def token
        config.push_key
      end
    end
  end
end
