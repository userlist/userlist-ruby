require 'userlist/version'
require 'userlist/config'
require 'userlist/push'

module Userlist
  class << self
    def config
      @config ||= Userlist::Config.new
    end
  end
end
