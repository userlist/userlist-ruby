module Userlist
  class Push
    module Operations
      module Create
        module ClassMethods
          def create(payload = {}, config = self.config)
            return false unless resource = from_payload(payload, config)

            strategy.call(:post, endpoint, resource) if resource.create?
          end

          alias push create
        end

        def self.included(base)
          base.extend(ClassMethods)
        end

        def create?
          push?
        end
      end
    end
  end
end
