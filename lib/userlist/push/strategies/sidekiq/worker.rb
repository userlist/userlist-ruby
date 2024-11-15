require 'sidekiq'

module Userlist
  class Push
    module Strategies
      class Sidekiq
        # Worker processes requests through Sidekiq.
        # It forwards requests to the Userlist::Push::Client which handles:
        # - HTTP communication
        # - Retries for failed requests (500s, timeouts, rate limits)
        # - Error handling for HTTP-related issues
        #
        # Note: Sidekiq retries (if configured) are separate from HTTP request retries
        class Worker
          include ::Sidekiq::Worker

          def perform(method, *args)
            client = Userlist::Push::Client.new
            client.public_send(method, *args)
          end
        end
      end
    end
  end
end
