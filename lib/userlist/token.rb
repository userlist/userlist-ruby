module Userlist
  class Token
    def self.generate(user, configuration = {})
      config = Userlist.config.merge(configuration)

      raise Userlist::ConfigurationError, :push_key unless config.push_key
      raise Userlist::ConfigurationError, :push_id unless config.push_id
      raise Userlist::ArgumentError, 'Missing required user or identifier' unless user

      user = Userlist::Push::User.from_payload(user, config)

      now = Time.now.utc.to_i

      header = {
        kid: config.push_id,
        alg: 'HS256'
      }

      payload = {
        sub: user.identifier,
        exp: now + config.token_lifetime,
        iat: now
      }

      new(payload: payload, header: header, key: config.push_key).to_s
    end

    def initialize(payload:, header:, key:, algorithm: 'HS256')
      @payload = payload
      @header = header
      @algorithm = algorithm
      @key = key
    end

    def encoded_header
      encode(header)
    end

    def encoded_payload
      encode(payload)
    end

    def encoded_header_and_payload
      "#{encoded_header}.#{encoded_payload}"
    end

    def signature
      digest = OpenSSL::Digest.new(algorithm.sub('HS', 'SHA'))
      signature = OpenSSL::HMAC.digest(digest, key, encoded_header_and_payload)

      encode(signature)
    end

    def to_s
      "#{encoded_header_and_payload}.#{signature}"
    end

  private

    attr_reader :payload, :header, :algorithm, :key

    def encode(payload)
      payload = JSON.generate(payload) unless payload.is_a?(String)

      Base64.urlsafe_encode64(payload).tr('=', '')
    end
  end
end
