module Userlist
  class Push
    module Operations
      module Delete
        module ClassMethods
          def delete(identifier)
            strategy.call(:delete, "#{endpoint}/#{identifier}")
          end
        end

        def included(base)
          base.extend(ClassMethods)
        end
      end
    end
  end
end
