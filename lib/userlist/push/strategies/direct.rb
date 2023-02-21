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
          @retryable ||= Userlist::Retryable.new do |response|
            status = response.code.to_i

            status >= 500 || status == 429
          end
        end
      end
    end
  end
end
