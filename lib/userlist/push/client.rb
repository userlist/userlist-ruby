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
        request = build_request(method, path, payload)

        logger.debug "Sending #{request.method} to #{URI.join(endpoint, request.path)} with body #{request.body}"

        response = process_request(request)

        logger.debug "Recieved #{response.code} #{response.message} with body #{response.body}"

        handle_response(response)
      end

      def build_request(method, path, payload)
        request = method.new(path)
        request['Accept'] = 'application/json'
        request['Authorization'] = "Push #{token}"
        request['Content-Type'] = 'application/json; charset=UTF-8'
        request.body = JSON.generate(payload) if payload
        request
      end

      def process_request(request)
        http.start unless http.started?
        http.request(request)
      rescue Timeout::Error => e
        raise Userlist::TimeoutError, e.message
      end

      def handle_response(response)
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
