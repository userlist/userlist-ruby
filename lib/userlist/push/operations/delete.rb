module Userlist
  class Push
    module Operations
      module Delete
        module ClassMethods
          def delete(payload = {}, config = self.config)
            return false unless resource = from_payload(payload, config)

            strategy.call(:delete, resource.url) if resource.delete?
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
