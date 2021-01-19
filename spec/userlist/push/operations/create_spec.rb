require 'spec_helper'

RSpec.describe Userlist::Push::Operations::Create do
  let(:resource_type) { Userlist::Push::User }
  let(:relation) { Userlist::Push::Relation.new(scope, resource_type, [described_class]) }
  let(:scope) { Userlist::Push.new(push_strategy: strategy) }
  let(:strategy) { instance_double('Userlist::Push::Strategies::Direct') }
  let(:resource) { resource_type.new(payload) }

  let(:payload) do
    {
      identifier: 'identifier',
      properties: {
        first_name: 'John',
        last_name: 'Doe'
      }
    }
  end

  describe '.create' do
    before do
      allow(strategy).to receive(:call)
    end

    it 'should create a new instance of the resource_type' do
      expect(resource_type).to receive(:new).with(payload, scope.config).and_return(resource)
      relation.create(payload)
    end

    it 'should be aliased as #push' do
      expect(relation.method(:push)).to eq(relation.method(:create))
    end

    context 'when given a payload hash' do
      it 'should send the payload to the endpoint' do
        expect(strategy).to receive(:call).with(:post, '/users', resource)
        relation.create(payload)
      end
    end

    context 'when given an identifier' do
      let(:payload) do
        { identifier: 'identifier' }
      end

      it 'should send a simple payload to the endpoint' do
        expect(strategy).to receive(:call).with(:post, '/users', resource)
        relation.create(payload[:identifier])
      end
    end

    context 'when given nil' do
      let(:payload) { nil }

      it 'should not send a payload to the endpoint' do
        expect(strategy).to_not receive(:call)
        relation.create(payload)
      end
    end
  end
end
