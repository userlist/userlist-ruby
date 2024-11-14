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

      attr_reader :config, :status, :last_error

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

        handle_response response
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
        status = response.code.to_i
        
        return response if status.between?(200, 299)
        
        case status
        when 500..599 then raise Userlist::ServerError, "Server error: #{status}"
        when 408 then raise Userlist::TimeoutError, 'Request timed out'
        when 429 then raise Userlist::TooManyRequestsError, 'Rate limited'
        else raise Userlist::Error, "HTTP #{status}: #{response.message}"
        end
      end

      def retry?(error)
        error.is_a?(Userlist::ServerError) || 
          error.is_a?(Userlist::TooManyRequestsError) ||
          error.is_a?(Userlist::TimeoutError)
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

      def retryable
        @retryable ||= Userlist::Retryable.new do |response|
          @status = response.code.to_i
      
          error?
        end
      end

      def ok?
        status.between?(200, 299)
      end

      def error?
        server_error? || rate_limited? || timeout?
      end
      
      def server_error?
        status.between?(500, 599)
      end
      
      def rate_limited?
        status == 429
      end

      def timeout?
        status == 408
      end
    end
  end
end