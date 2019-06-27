require 'spec_helper'

RSpec.describe Userlist::Push::Strategies::Threaded::Worker do
  subject { described_class.new(queue, config) }

  let(:queue) { Queue.new }
  let(:config) { Userlist.config.merge(push_key: 'other-key') }
  let(:client) { instance_double('Userlist::Push::Client') }
  let(:logger) { TestLogger.new }

  let(:payload) do
    { foo: :bar }
  end

  before do
    allow(Userlist).to receive(:logger).and_return(logger)
    allow(Userlist::Push::Client).to receive(:new).and_return(client)
    allow(client).to receive(:post)
  end

  after do
    subject.stop
  end

  it 'should pass on the configuration' do
    expect(Userlist::Push::Client).to receive(:new).with(config).and_return(client)
    queue.push([:post, '/events', payload])
  end

  it 'should process the queue' do
    expect(client).to receive(:post).with('/events', payload).exactly(5).times
    5.times { queue.push([:post, '/events', payload]) }
  end

  it 'should process requests with and without payload' do
    expect(client).to receive(:post).with('/user', payload).once
    expect(client).to receive(:delete).with('/user/identifier').once

    queue.push([:post, '/user', payload])
    queue.push([:delete, '/user/identifier'])
  end

  it 'should log failed requests' do
    allow(client).to receive(:post).and_raise(StandardError)
    queue.push([:post, '/events', payload])
    subject.stop
    expect(logger.messages).to match(/Failed to deliver payload: \[StandardError\]/)
  end

  it 'should log the workers lifecycle' do
    queue.push([:post, '/events', payload])
    subject.stop
    expect(logger.messages).to match(/Starting worker thread.../)
    expect(logger.messages).to match(/Stopping worker thread.../)
    expect(logger.messages).to match(/Worker thread exited with 0 tasks still in the queue.../)
  end
end
