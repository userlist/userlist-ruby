module Userlist
  class Push
    module Operations
      module Delete
        module ClassMethods
          def delete(payload = {}, config = self.config)
            return false unless resource = from_payload(payload, config)
            return false unless resource.delete?

            strategy.call(:delete, endpoint, resource.for_context(:delete))
          end
        end

        def self.included(base)
          base.extend(ClassMethods)
        end

        def delete?
          true
        end
      end
    end
  end
end
