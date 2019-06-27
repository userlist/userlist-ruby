module Userlist
  class Push
    module Strategies
      class Threaded
        class Worker
          include Userlist::Logging

          MAX_WORKER_TIMEOUT = 30

          def initialize(queue, config = {})
            @queue = queue
            @config = Userlist.config.merge(config)
            @thread = Thread.new { run }
            @thread.abort_on_exception = true
          end

          def run
            logger.info 'Starting worker thread...'

            loop do
              begin
                method, *args = *queue.pop
                break if method == :stop

                client.public_send(method, *args)
              rescue StandardError => e
                logger.error "Failed to deliver payload: [#{e.class.name}] #{e.message}"
              end
            end

            logger.info "Worker thread exited with #{queue.size} tasks still in the queue..."
          end

          def stop
            logger.info 'Stopping worker thread...'
            queue.push([:stop])
            thread.join(MAX_WORKER_TIMEOUT)
          end

        private

          attr_reader :queue, :config, :thread

          def client
            @client ||= Userlist::Push::Client.new(config)
          end
        end
      end
    end
  end
end
