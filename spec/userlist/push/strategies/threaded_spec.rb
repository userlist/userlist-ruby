require 'spec_helper'

RSpec.describe Userlist::Push::Strategies::Threaded do
  subject { described_class.new(config) }

  let(:config) { Userlist.config.merge(push_key: 'other-key') }
  let(:worker) { nil }
  let(:queue) { [] }

  before do
    allow(Queue).to receive(:new).and_return(queue)
    allow(described_class::Worker)
      .to receive(:new).and_return(worker)
  end

  it 'should pass on the configuration' do
    expect(described_class::Worker)
      .to receive(:new).with(queue, config).and_return(worker)
    subject.call(:post, '/users', {})
  end

  it 'should put the requests into the queue' do
    subject.call(:post, '/users', {})
    expect(queue).to eq([[:post, '/users', {}]])
  end
end
