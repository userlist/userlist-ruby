require 'uri'
require 'json'
require 'net/http'
require 'openssl'

module Userlist
  class Push
    class Client
      include Userlist::Logging

      def initialize(config = {})
        @config = Userlist.config.merge(config)

        raise Userlist::ConfigurationError, :push_key unless @config.push_key
        raise Userlist::ConfigurationError, :push_endpoint unless @config.push_endpoint
      end

      def get(endpoint)
        request(Net::HTTP::Get, endpoint)
      end

      def post(endpoint, payload = nil)
        request(Net::HTTP::Post, endpoint, payload)
      end

      def put(endpoint, payload = nil)
        request(Net::HTTP::Put, endpoint, payload)
      end

      def delete(endpoint, payload = nil)
        request(Net::HTTP::Delete, endpoint, payload)
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

      def request(method, path, payload = nil)
        request = method.new(path)
        request['Accept'] = 'application/json'
        request['Authorization'] = "Push #{token}"
        request['Content-Type'] = 'application/json; charset=UTF-8'
        request.body = JSON.generate(payload) if payload

        logger.debug "Sending #{request.method} to #{URI.join(endpoint, request.path)} with body #{request.body}"

        http.start unless http.started?
        response = http.request(request)

        logger.debug "Recieved #{response.code} #{response.message} with body #{response.body}"

        raise(Userlist::RequestError, response) if response.code.to_i >= 400

        response
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
