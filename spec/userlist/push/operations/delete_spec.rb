require 'spec_helper'

RSpec.describe Userlist::Push::Operations::Delete do
  let(:resource_type) { Userlist::Push::User }
  let(:relation) { Userlist::Push::Relation.new(scope, resource_type, [described_class]) }
  let(:scope) { Userlist::Push.new(push_strategy: strategy) }
  let(:strategy) { instance_double('Userlist::Push::Strategies::Direct') }
  let(:resource) { resource_type.from_payload(payload) }

  describe '.delete' do
    let(:identifier) { 'identifier' }

    context 'when given an identifier' do
      let(:payload) { identifier }

      it 'should send the request to the endpoint' do
        expect(strategy).to receive(:call).with(:delete, '/users', resource)
        relation.delete(payload)
      end

      it 'should set the context to :create' do
        expect(strategy).to receive(:call).with(:delete, '/users', satisfy { |r| r.context == :delete })
        relation.delete(payload)
      end
    end

    context 'when given a payload hash' do
      let(:payload) do
        { identifier: identifier }
      end

      it 'should send the request to the endpoint' do
        expect(strategy).to receive(:call).with(:delete, '/users', resource)
        relation.delete(payload)
      end

      it 'should set the context to :create' do
        expect(strategy).to receive(:call).with(:delete, '/users', satisfy { |r| r.context == :delete })
        relation.delete(payload)
      end
    end

    context 'when given a resource instance' do
      let(:payload) { resource_type.from_payload({ identifier: identifier }) }

      it 'should send the request to the endpoint' do
        expect(strategy).to receive(:call).with(:delete, '/users', resource)
        relation.delete(payload)
      end

      it 'should set the context to :create' do
        expect(strategy).to receive(:call).with(:delete, '/users', satisfy { |r| r.context == :delete })
        relation.delete(payload)
      end
    end

    context 'when given nil' do
      let(:payload) { nil }

      it 'should not send a payload to the endpoint' do
        expect(strategy).to_not receive(:call)
        relation.delete(payload)
      end
    end

    context 'when the operation is not permitted' do
      before do
        allow_any_instance_of(resource_type).to receive(:delete?).and_return(false)
      end

      it 'should not send a payload to the endpoint' do
        expect(strategy).to_not receive(:call)
        relation.delete(identifier)
      end
    end
  end
end
