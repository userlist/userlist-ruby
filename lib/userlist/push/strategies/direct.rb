module Userlist
  class Push
    module Strategies
      class Direct
        def initialize(config = {})
          @config = Userlist.config.merge(config)
        end

        def call(*args)
          client.public_send(*args)
        end

      private

        attr_reader :config

        def client
          @client ||= Userlist::Push::Client.new(config)
        end
      end
    end
  end
end
