require 'userlist/version'
require 'userlist/config'

module Userlist
  class << self
    def config
      @config ||= Userlist::Config.new
    end
  end
end
