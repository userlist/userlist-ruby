require 'sidekiq'

module Userlist
  class Push
    module Strategies
      class Sidekiq
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
