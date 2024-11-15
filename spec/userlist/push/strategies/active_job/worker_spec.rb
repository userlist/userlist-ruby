require 'spec_helper'

require 'userlist/push/strategies/active_job/worker'

RSpec.describe Userlist::Push::Strategies::ActiveJob::Worker do
  subject { described_class.new(queue, config) }

  let(:client) { instance_double('Userlist::Push::Client') }

  let(:payload) do
    { 'foo' => 'bar' }
  end

  before do
    allow(Userlist::Push::Client).to receive(:new).and_return(client)
    allow(client).to receive(:post)
  end

  it 'should process the job' do
    expect(client).to receive(:post).with('/events', payload).exactly(5).times
    5.times { described_class.perform_now('post', '/events', payload) }
  end

  it 'should process requests with and without payload' do
    expect(client).to receive(:post).with('/user', payload).once
    expect(client).to receive(:delete).with('/user/identifier').once

    described_class.perform_now('post', '/user', payload)
    described_class.perform_now('delete', '/user/identifier')
  end

  it 'should retry the job on failure' do
    allow(client).to receive(:post).and_raise(Userlist::RequestError.new(double(code: '500', body: 'Internal Error')))

    expect { described_class.perform_now('post', '/events', payload) }
      .to change(described_class.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'should retry the job on timeouts' do
    allow(client).to receive(:post).and_raise(Userlist::TimeoutError)

    expect { described_class.perform_now('post', '/events', payload) }
      .to change(described_class.queue_adapter.enqueued_jobs, :size).by(1)
  end
end
