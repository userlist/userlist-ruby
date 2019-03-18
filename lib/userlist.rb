require 'logger'

require 'userlist/version'
require 'userlist/config'
require 'userlist/logging'
require 'userlist/push'

module Userlist
  class << self
    def config
      @config ||= Userlist::Config.new
    end

    def logger
      @logger ||= begin
        logger = Logger.new(STDOUT)
        logger.progname = 'userlist'
        logger.level = Logger.const_get(config.log_level.to_s.upcase)
        logger
      end
    end

    def configure
      yield config
    end

    attr_writer :logger
  end
end
