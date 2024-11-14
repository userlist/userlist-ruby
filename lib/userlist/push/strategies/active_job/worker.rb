require 'active_job'

module Userlist
  class Push
    module Strategies
      class ActiveJob
        class Worker < ::ActiveJob::Base
          def perform(method, *args)
            client = Userlist::Push::Client.new
            client.public_send(method, *args)
          end
        end
      end
    end
  end
end
