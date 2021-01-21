require 'spec_helper'

require 'userlist/push/strategies/sidekiq'
require 'sidekiq/testing'

RSpec.describe Userlist::Push::Strategies::Sidekiq do
  subject { described_class.new(config) }

  let(:config) { { push_strategy_options: push_strategy_options } }
  let(:push_strategy_options) { {} }
  let(:job) { queue.first }
  let(:queue) { Sidekiq::Queues['default'] }

  before do
    Sidekiq::Queues.clear_all
  end

  it 'should enqueue the default worker' do
    subject.call(:post, '/users', {})
    expect(job['class']).to eq('Userlist::Push::Strategies::Sidekiq::Worker')
  end

  it 'should use the default queue' do
    expect { subject.call(:post, '/users', {}) }
      .to change { queue.size }.by(1)
  end

  it 'should pass along the arguments' do
    subject.call(:post, '/users', {})
    expect(job['args']).to eq(['post', '/users', {}])
  end

  context 'when there is a custom queue given' do
    let(:queue) { Sidekiq::Queues['userlist'] }

    let(:push_strategy_options) do
      { queue: 'userlist' }
    end

    it 'should use the given queue' do
      expect { subject.call(:post, '/users', {}) }
        .to change { queue.size }.by(1)
    end
  end

  context 'when there is a custom worker given' do
    let(:push_strategy_options) do
      { class: 'TestWorker' }
    end

    it 'should use the given queue' do
      subject.call(:post, '/users', {})
      expect(job['class']).to eq('TestWorker')
    end
  end

  context 'when there are other custom options' do
    let(:push_strategy_options) do
      { retry: 42 }
    end

    it 'should pass along the other options' do
      subject.call(:post, '/users', {})
      expect(job['retry']).to eq(42)
    end
  end
end
