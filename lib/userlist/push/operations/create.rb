module Userlist
  class Push
    module Operations
      module Create
        module ClassMethods
          def create(payload = {}, config = self.config)
            resource = from_payload(payload, config)
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
