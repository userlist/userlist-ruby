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
        logger.level = config.log_level
        logger
      end
    end
  end
end
