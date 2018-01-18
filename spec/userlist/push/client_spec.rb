require 'spec_helper'

RSpec.describe Userlist::Push::Client do
  subject { described_class.new(config) }

  let(:config) do
    Userlist::Config.new(push_key: 'test-push-key', push_endpoint: 'https://endpoint.test.local')
  end

  describe '#post' do
    it 'should send the payload to the given endpoint' do
      payload = { foo: :bar }

      stub_request(:post, 'https://endpoint.test.local/events')
        .with(
          body: JSON.dump(payload),
          headers: {
            'Accept' => 'application/json',
            'Content-Type' => 'application/json; charset=UTF-8',
            'Authorization' => 'Push test-push-key'
          }
        )
        .to_return(status: 202)

      subject.post('/events', payload)
    end
  end
end
