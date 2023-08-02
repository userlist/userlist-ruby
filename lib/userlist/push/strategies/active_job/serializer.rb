require 'active_job'

module Userlist
  class Push
    module Strategies
      class ActiveJob
        class Serializer < ::ActiveJob::Serializers::ObjectSerializer
          def serialize(resource)
            super(resource.to_hash.merge(type: resource.class.to_s))
          end

          def deserialize(hash)
            hash.except!(::ActiveJob::Arguments::OBJECT_SERIALIZER_KEY)
            type = hash.delete(:type)

            raise ArgumentError, 'No type key found' unless type

            klass = type.safe_constantize

            raise ArgumentError, "No klass for type #{type}" unless klass

            klass.new(hash)
          end

        private

          def klass
            Userlist::Push::Resource
          end
        end
      end
    end
  end
end

ActiveJob::Serializers.add_serializers Userlist::Push::Strategies::ActiveJob::Serializer
