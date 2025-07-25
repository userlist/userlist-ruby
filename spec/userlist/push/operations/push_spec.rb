require 'spec_helper'

RSpec.describe Userlist::Push::Operations::Push do
  let(:resource_type) { Userlist::Push::User }
  let(:relation) { Userlist::Push::Relation.new(scope, resource_type, [described_class]) }
  let(:scope) { Userlist::Push.new(push_strategy: strategy) }
  let(:strategy) { instance_double('Userlist::Push::Strategies::Direct') }
  let(:resource) { resource_type.from_payload(payload) }

  let(:identifier) { 'identifier' }
  let(:payload) do
    {
      identifier: identifier,
      properties: {
        first_name: 'John',
        last_name: 'Doe'
      }
    }
  end

  describe '.push' do
    before do
      allow(strategy).to receive(:call)
    end

    it 'should create a new instance of the resource_type' do
      expect(resource_type).to receive(:new).with(payload, scope.config).and_return(resource)
      relation.push(payload)
    end

    it 'should be aliased as #push' do
      expect(relation.method(:push)).to eq(relation.method(:push))
    end

    context 'when given a payload hash' do
      it 'should send the payload to the endpoint' do
        expect(strategy).to receive(:call).with(:post, '/users', resource)
        relation.push(payload)
      end

      it 'should set the context to :push' do
        expect(strategy).to receive(:call).with(:post, '/users', satisfy { |r| r.options[:context] == :push })
        relation.push(payload)
      end
    end

    context 'when given a resource instance' do
      let(:payload) { resource_type.from_payload({ identifier: 'identifier' }) }

      it 'should send the request to the endpoint' do
        expect(strategy).to receive(:call).with(:post, '/users', resource)
        relation.push(payload)
      end

      it 'should set the context to :push' do
        expect(strategy).to receive(:call).with(:post, '/users', satisfy { |r| r.options[:context] == :push })
        relation.push(payload)
      end
    end

    context 'when given an identifier' do
      let(:payload) do
        { identifier: identifier }
      end

      it 'should send a simple payload to the endpoint' do
        expect(strategy).to receive(:call).with(:post, '/users', resource)
        relation.push(payload[:identifier])
      end
    end

    context 'when given nil' do
      let(:payload) { nil }

      it 'should not send a payload to the endpoint' do
        expect(strategy).to_not receive(:call)
        relation.push(payload)
      end
    end

      context 'when given keyword arguments as payload' do
      let(:payload) do
        { identifier: identifier }
      end

      it 'should send the request to the endpoint' do
        expect(strategy).to receive(:call).with(:post, '/users', resource.with(context: :push))
        relation.push(identifier:)
      end
    end

    context 'when the operation is not permitted' do
      before do
        allow_any_instance_of(resource_type).to receive(:push?).and_return(false)
      end

      it 'should not send a payload to the endpoint' do
        expect(strategy).to_not receive(:call)
        relation.push(payload)
      end
    end

    context 'when push ist not permitted' do
      before do
        allow_any_instance_of(resource_type).to receive(:push?).and_return(false)
      end

      it 'should not allow the operation' do
        expect(resource.push?).to be(false)
      end
    end
  end

  describe '.create' do
    it 'should be an alias for push' do
      expect(relation.method(:create)).to eq(relation.method(:push))
    end
  end

  describe '.update' do
    it 'should be an alias for push' do
      expect(relation.method(:update)).to eq(relation.method(:push))
    end
  end
end
