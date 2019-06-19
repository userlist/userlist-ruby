require 'spec_helper'

RSpec.describe Userlist::Push::Client do
  subject { described_class.new(config) }

  let(:config) do
    Userlist::Config.new(push_key: 'test-push-key', push_endpoint: 'https://endpoint.test.local')
  end

  describe '#get' do
    it 'should send the request to the given endpoint' do
      stub_request(:get, 'https://endpoint.test.local/events')
        .with(
          headers: {
            'Accept' => 'application/json',
            'Content-Type' => 'application/json; charset=UTF-8',
            'Authorization' => 'Push test-push-key'
          }
        )
        .to_return(status: 202)

      subject.get('/events')
    end
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

  describe '#put' do
    it 'should send the payload to the given endpoint' do
      payload = { foo: :bar }

      stub_request(:put, 'https://endpoint.test.local/events')
        .with(
          body: JSON.dump(payload),
          headers: {
            'Accept' => 'application/json',
            'Content-Type' => 'application/json; charset=UTF-8',
            'Authorization' => 'Push test-push-key'
          }
        )
        .to_return(status: 202)

      subject.put('/events', payload)
    end
  end

  describe '#delete' do
    it 'should send the request to the given endpoint' do
      stub_request(:delete, 'https://endpoint.test.local/events')
        .with(
          headers: {
            'Accept' => 'application/json',
            'Content-Type' => 'application/json; charset=UTF-8',
            'Authorization' => 'Push test-push-key'
          }
        )
        .to_return(status: 202)

      subject.delete('/events')
    end
  end
end
