require 'logger'

require 'userlist/version'
require 'userlist/config'
require 'userlist/logging'
require 'userlist/retryable'
require 'userlist/push'
require 'userlist/token'

module Userlist
  class Error < StandardError; end

  class ArgumentError < Error; end

  class ConfigurationError < Error
    attr_reader :key

    def initialize(key)
      @key = key.to_sym

      super(<<~MESSAGE)
        Missing required configuration value for `#{key}`

        Please set a value for `#{key}` using an environment variable:

          USERLIST_#{key.to_s.upcase}=some-value-here

        or via the `Userlist.configure` method:

          Userlist.configure do |config|
            config.#{key} = 'some-value-here'
          end
      MESSAGE
    end
  end

  class RequestError < Error
    attr_reader :response

    def initialize(response)
      super("Request failed with status #{response.code}: #{response.body}")

      @response = response
    end

    def status
      @response.code.to_i
    end
  end

  class << self
    def config
      @config ||= Userlist::Config.new
    end

    def logger
      @logger ||= begin
        logger = Logger.new($stdout)
        logger.progname = 'userlist'
        logger.level = Logger.const_get(config.log_level.to_s.upcase)
        logger
      end
    end

    def configure
      yield config
    end

    def reset!
      @config = nil
    end

    attr_writer :logger
  end
end
