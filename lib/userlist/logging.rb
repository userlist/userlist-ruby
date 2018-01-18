module Userlist
  module Logging
    def self.included(mod)
      mod.send(:extend, self)
    end

    def logger
      Userlist.logger
    end
  end
end
