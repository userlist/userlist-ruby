module Userlist
  class Push
    module Operations
      module Delete
        module ClassMethods
          def delete(payload = {}, config = self.config)
            return false unless resource = from_payload(payload, config)

            strategy.call(:delete, resource.url)
          end
        end

        def included(base)
          base.extend(ClassMethods)
        end
      end
    end
  end
end
