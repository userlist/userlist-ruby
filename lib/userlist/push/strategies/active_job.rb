require 'active_job'

require 'userlist/push/strategies/active_job/serializer'
require 'userlist/push/strategies/active_job/worker'

module Userlist
  class Push
    module Strategies
      class ActiveJob
        def initialize(config = {})
          @config = Userlist.config.merge(config)
        end

        def call(*args)
          options = default_options.merge(self.options)

          worker_name = options.delete(:class)
          worker_class = Object.const_get(worker_name)
          worker_class
            .set(options)
            .perform_later(*args)
        end

      private

        attr_reader :config

        def options
          @options ||= begin
            options = config.push_strategy_options || {}
            options.each_with_object({}) { |(k, v), h| h[k.to_sym] = v }
          end
        end

        def default_options
          {
            class: 'Userlist::Push::Strategies::ActiveJob::Worker',
            queue: 'default'
          }
        end
      end
    end
  end
end
