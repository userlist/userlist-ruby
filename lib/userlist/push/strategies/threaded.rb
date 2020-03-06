require 'userlist/push/strategies/threaded/worker'

module Userlist
  class Push
    module Strategies
      class Threaded
        def initialize(config = {})
          @queue = Queue.new
          @worker = Worker.new(queue, config)

          at_exit { stop_worker }
        end

        def call(*args)
          queue.push(args)
        end

      private

        attr_reader :queue, :worker

        def stop_worker
          worker&.stop
        end
      end
    end
  end
end
