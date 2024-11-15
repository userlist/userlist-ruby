require 'active_job'

module Userlist
  class Push
    module Strategies
      class ActiveJob
        class Worker < ::ActiveJob::Base
          retry_on Userlist::TimeoutError, Userlist::RequestError, wait: :polynomially_longer, attempts: 10

          def perform(method, *args)
            client = Userlist::Push::Client.new
            client.public_send(method, *args)
          end
        end
      end
    end
  end
end
