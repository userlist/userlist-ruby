require 'spec_helper'

require 'userlist/push/strategies/active_job'

RSpec.describe Userlist::Push::Strategies::ActiveJob do
  subject { described_class.new(config) }

  let(:queue_adapter) { ActiveJob::QueueAdapters::TestAdapter.new }
  let(:job) { queue_adapter.enqueued_jobs.first }

  before do
    ActiveJob::Base.queue_adapter = queue_adapter
  end

  let(:config) { { push_strategy_options: push_strategy_options } }
  let(:push_strategy_options) { {} }

  it 'should enqueue the default worker' do
    subject.call(:post, '/users', {})
    expect(job['job_class']).to eq('Userlist::Push::Strategies::ActiveJob::Worker')
  end

  it 'should use the default queue' do
    subject.call(:post, '/users', {})
    expect(job['queue_name']).to eq('default')
  end

  it 'should pass along the arguments' do
    subject.call(:post, '/users', {})
    expect(job['arguments']).to eq(ActiveJob::Arguments.serialize([:post, '/users', {}]))
  end

  context 'when there is a custom queue given' do
    let(:push_strategy_options) do
      { queue: 'userlist' }
    end

    it 'should use the given queue' do
      subject.call(:post, '/users', {})
      expect(job['queue_name']).to eq('userlist')
    end
  end

  context 'when there is a custom worker given' do
    let(:push_strategy_options) do
      { class: 'TestWorker' }
    end

    before do
      Object.const_set(:TestWorker, Class.new(ActiveJob::Base))
    end

    after do
      Object.send(:remove_const, :TestWorker)
    end

    it 'should use the given queue' do
      subject.call(:post, '/users', {})
      expect(job['job_class']).to eq('TestWorker')
    end
  end

  context 'when there are other custom options' do
    let(:push_strategy_options) do
      { priority: 42 }
    end

    it 'should pass along the other options' do
      subject.call(:post, '/users', {})
      expect(job['priority']).to eq(42)
    end
  end
end
