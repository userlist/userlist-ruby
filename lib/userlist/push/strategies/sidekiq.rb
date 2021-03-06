require 'sidekiq'

require 'userlist/push/strategies/sidekiq/worker'

module Userlist
  class Push
    module Strategies
      class Sidekiq
        def initialize(config = {})
          @config = Userlist.config.merge(config)
        end

        def call(*args)
          ::Sidekiq::Client.push(default_options.merge(options).merge('args' => args))
        end

      private

        attr_reader :config

        def options
          @options ||= begin
            options = config.push_strategy_options || {}
            options.each_with_object({}) { |(k, v), h| h[k.to_s] = v }
          end
        end

        def default_options
          {
            'class' => 'Userlist::Push::Strategies::Sidekiq::Worker',
            'queue' => 'default'
          }
        end
      end
    end
  end
end
