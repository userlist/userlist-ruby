require 'spec_helper'

require 'userlist/push/strategies/direct'

RSpec.describe Userlist::Push::Strategies::Direct do
  subject { described_class.new(config) }

  let(:client) { instance_double('Userlist::Push::Client') }
  let(:config) do
    Userlist::Config.new(push_key: 'test-push-key', push_endpoint: 'https://endpoint.test.local')
  end

  before do
    allow(Userlist::Push::Client).to receive(:new).and_return(client)
    allow(client).to receive(:post) { double(code: '202') }
  end

  it 'should pass on the configuration' do
    config = Userlist.config.merge(push_key: 'other-key')
    expect(Userlist::Push::Client).to receive(:new).with(config).and_return(client)
    strategy = described_class.new(config)
    strategy.call(:post, '/users', {})
  end

  describe '#call' do
    it 'should forward the call to the client' do
      payload = { foo: :bar }
      expect(client).to receive(:post).with('/users', payload)
      subject.call(:post, '/users', payload)
    end
  end
end
