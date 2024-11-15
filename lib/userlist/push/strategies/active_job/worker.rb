require 'active_job'

module Userlist
  class Push
    module Strategies
      class ActiveJob
        # Worker processes requests through ActiveJob.
        # It forwards requests to the Userlist::Push::Client which handles:
        # - HTTP communication
        # - Retries for failed requests (500s, timeouts, rate limits)
        # - Error handling for HTTP-related issues
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
