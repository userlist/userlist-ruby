module Userlist
  class Retryable
    include Userlist::Logging

    RETRIES = 10
    DELAY = 100
    MULTIPLIER = 2
    MAX_DELAY = 10_000

    def initialize(retries: RETRIES, delay: DELAY, max_delay: MAX_DELAY, multiplier: MULTIPLIER, &retry_check)
      @retries = retries
      @delay = delay
      @max_delay = max_delay
      @multiplier = multiplier
      @retry_check = retry_check
    end

    def retry?(value)
      @retry_check.call(value)
    end

    def attempt
      result = nil
      (0..@retries).each do |attempt|
        if attempt.positive?
          milliseconds = delay(attempt)
          logger.debug "Retrying in #{milliseconds}ms, #{@retries - attempt} retries left"
          sleep(milliseconds / 1000.0)
        end

        result = yield

        return result unless retry?(result)
      end

      logger.debug 'Retries exhausted, giving up'
      result
    end

  private

    def delay(attempt)
      [
        @delay * (@multiplier ** attempt),
        @max_delay
      ].min
    end
  end
end
