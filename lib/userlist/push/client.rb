require 'uri'
require 'json'
require 'net/http'
require 'openssl'

module Userlist
  class Push
    class Client
      include Userlist::Logging

      HTTP_STATUS = {
        ok: (200..299),
        server_error: (500..599),
        timeout: 408,
        rate_limit: 429
      }.freeze

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

      attr_reader :config, :status

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

        log_request(request)

        http.start unless http.started?

        response = retryable.attempt do
          response = http.request(request)
          log_response(response)
        end

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

      def handle_response(response)
        @status = response.code.to_i
        return response if ok?

        raise_error_for_status(status)
      end

      def raise_error_for_status(status)
        error_class = error_class_for_status(status)
        message = error_message_for_status(status)
        raise error_class, message
      end

      def error_class_for_status(status)
        error_mapping[status_type(status)] || Userlist::ServerError
      end

      def error_message_for_status(status)
        message = error_messages[status_type(status)] || 'HTTP error'
        "#{message}: #{status}"
      end

      def status_type(status)
        HTTP_STATUS.find { |type, range| range === status }&.first
      end

      def error_mapping
        {
          server_error: Userlist::ServerError,
          timeout: Userlist::TimeoutError,
          rate_limit: Userlist::TooManyRequestsError
        }
      end

      def error_messages
        {
          server_error: 'Server error',
          timeout: 'Request timeout',
          rate_limit: 'Rate limit exceeded'
        }
      end

      def ok?
        HTTP_STATUS[:ok].include?(status)
      end

      def error?
        [:server_error, :rate_limit, :timeout].include?(status_type(status))
      end

      def retryable
        @retryable ||= Userlist::Retryable.new do |response|
          @status = response.code.to_i

          error?
        end
      end

      def log_request(request)
        logger.debug "Sending #{request.method} to #{URI.join(endpoint, request.path)} with body #{request.body}"
      end

      def log_response(response)
        logger.debug "Received #{response.code} #{response.message} with body #{response.body}"
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
