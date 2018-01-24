require 'spec_helper'

RSpec.describe Userlist::Push::Strategies::Direct do
  subject { described_class.new }

  let(:client) { instance_double('Userlist::Push::Client') }

  before do
    allow(client).to receive(:post)
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
  end
end
