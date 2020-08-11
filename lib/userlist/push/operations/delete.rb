module Userlist
  class Push
    module Operations
      module Delete
        module ClassMethods
          def delete(payload = {})
            resource = from_payload(payload)
            strategy.call(:delete, "#{endpoint}/#{resource.identifier}")
          end
        end

        def included(base)
          base.extend(ClassMethods)
        end
      end
    end
  end
end
