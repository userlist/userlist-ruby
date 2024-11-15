require 'spec_helper'

require 'userlist/push/strategies/direct'

RSpec.describe Userlist::Push::Strategies::Direct do
  subject { described_class.new }

  let(:client) { instance_double('Userlist::Push::Client') }

  before do
    allow(client).to receive(:post) { double(code: '202') }
  end

  it 'should pass on the configuration' do
    config = Userlist.config.merge(push_key: 'other-key')
    expect(Userlist::Push::Client).to receive(:new).with(config).and_return(client)
    strategy = described_class.new(config)
    strategy.call(:post, '/users', {})
  end

  describe '#call' do
    before do
      allow(Userlist::Push::Client).to receive(:new).and_return(client)
    end

    it 'should forward the call to the client' do
      payload = { foo: :bar }
      expect(client).to receive(:post).with('/users', payload)
      subject.call(:post, '/users', payload)
    end

    it 'should retry failed responses' do
      payload = { foo: :bar }

      expect(client).to receive(:post) { raise Userlist::RequestError, double(code: '500', body: 'Internal Error') }.exactly(11).times
      expect_any_instance_of(Userlist::Retryable).to receive(:sleep).exactly(10).times

      subject.call(:post, '/users', payload)
    end
  end
end
