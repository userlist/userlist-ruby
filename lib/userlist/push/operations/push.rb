module Userlist
  class Push
    module Operations
      module Push
        module ClassMethods
          def push(payload = {}, config = self.config)
            return false unless resource = from_payload(payload, config)
            return false unless resource.push?

            strategy.call(:post, endpoint, resource.for_context(:push))
          end

          alias create push
          alias update push
        end

        def self.included(base)
          base.extend(ClassMethods)
        end
      end
    end
  end
end
