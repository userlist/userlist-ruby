module Userlist
  class Push
    module Strategies
      class Direct
        def initialize(config = {})
          @config = Userlist.config.merge(config)
        end

        def call(*args)
          retryable.attempt { client.public_send(*args) }
        end

      private

        attr_reader :config

        def client
          @client ||= Userlist::Push::Client.new(config)
        end

        def retryable
          @retryable ||= Userlist::Retryable.new do |error|
            case error
            when Userlist::RequestError
              status = error.status
              status >= 500 || status == 429
            when Userlist::TimeoutError
              true
            else
              false
            end
          end
        end
      end
    end
  end
end
