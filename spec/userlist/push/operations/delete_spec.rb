require 'spec_helper'

RSpec.describe Userlist::Push::Operations::Delete do
  let(:resource_type) { Userlist::Push::User }
  let(:relation) { Userlist::Push::Relation.new(scope, resource_type, [described_class]) }
  let(:scope) { Userlist::Push.new(push_strategy: strategy) }
  let(:strategy) { instance_double('Userlist::Push::Strategies::Direct') }

  describe '.delete' do
    let(:identifier) { 'identifier' }

    context 'when given an identifier' do
      it 'should send the request to the endpoint' do
        expect(strategy).to receive(:call).with(:delete, '/users/identifier')
        relation.delete(identifier)
      end
    end

    context 'when given a payload hash' do
      let(:payload) do
        { identifier: identifier }
      end

      it 'should send the request to the endpoint' do
        expect(strategy).to receive(:call).with(:delete, '/users/identifier')
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
  end
end
