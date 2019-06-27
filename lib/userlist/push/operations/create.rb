module Userlist
  class Push
    module Operations
      module Create
        module ClassMethods
          def create(payload = {})
            resource = from_payload(payload)
            strategy.call(:post, endpoint, resource.attributes)
          end

          alias push create
        end

        def included(base)
          base.extend(ClassMethods)
        end
      end
    end
  end
end
