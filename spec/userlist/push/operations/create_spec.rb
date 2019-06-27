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

    it 'should send the payload to the endpoint' do
      expect(strategy).to receive(:call).with(:post, '/users', payload)
      relation.create(payload)
    end

    it 'should create a new instance of the resource_type' do
      expect(resource_type).to receive(:new).with(payload).and_return(resource)
      relation.create(payload)
    end
  end
end
