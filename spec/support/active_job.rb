require 'active_job'

ActiveJob::Base.queue_adapter = :test
ActiveJob::Base.logger = Logger.new(nil)
