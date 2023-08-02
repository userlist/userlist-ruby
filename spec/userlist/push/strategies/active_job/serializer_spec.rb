require 'spec_helper'

require 'userlist/push/strategies/active_job'

RSpec.describe Userlist::Push::Strategies::ActiveJob::Serializer do
  let(:queue_adapter) { ActiveJob::QueueAdapters::TestAdapter.new }
  let(:job) { queue_adapter.enqueued_jobs.first }
  let(:resource) { Userlist::Push::User.new(resource_payload) }
  let(:resource_payload) { { identifier: 'foo' } }
  let(:serialized_resource) { ActiveJob::Arguments.send(:serialize_argument, resource) }

  before do
    ActiveJob::Base.queue_adapter = queue_adapter
  end

  let(:config) { { push_strategy_options: push_strategy_options } }
  let(:push_strategy_options) { {} }

  describe '#serialize' do
    subject { described_class.serialize(resource) }

    it 'should correctly serialize resource with type' do
      is_expected.to eq(serialized_resource)
    end
  end

  describe '#deserialize' do
    subject { described_class.deserialize(serialized_resource) }

    it 'should correctly deserialize klass from type key' do
      is_expected.to be_kind_of(resource.class)
    end

    it 'should have correct payload for resource' do
      expect(subject.to_hash).to eq resource_payload
    end
  end
end
