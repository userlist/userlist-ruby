require 'spec_helper'

RSpec.describe Userlist::Push::Client do
  subject { described_class.new(config) }

  let(:config) do
    Userlist::Config.new(push_key: 'test-push-key', push_endpoint: 'https://endpoint.test.local')
  end

  describe '#initialize' do
    context 'when using the default configuration' do
      before do
        ENV['USERLIST_PUSH_KEY'] = 'test-push-key'
      end

      it 'should not raise an error message' do
        expect { described_class.new }.to_not raise_error
      end
    end

    context 'when configured using a hash' do
      let(:config) { { push_key: 'test-push-key' } }

      it 'should not raise an error message' do
        expect { described_class.new(config) }.to_not raise_error
      end
    end

    context 'when the push_key is missing' do
      let(:config) do
        Userlist::Config.new(push_key: nil, push_endpoint: 'https://endpoint.test.local')
      end

      it 'should raise an error message' do
        expect { subject }.to raise_error(Userlist::ConfigurationError, /push_key/)
      end
    end

    context 'when the push_endpoint is missing' do
      let(:config) do
        Userlist::Config.new(push_key: 'test-push-key', push_endpoint: nil)
      end

      it 'should raise an error message' do
        expect { subject }.to raise_error(Userlist::ConfigurationError, /push_endpoint/)
      end
    end
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

    it 'retries on server errors (500s), timeouts (408), and rate limits (429)' do
      stub_request(:post, 'https://endpoint.test.local/events')
        .to_return(
          { status: 500 },  # First attempt fails with server error
          { status: 408 },  # Second attempt fails with timeout
          { status: 429 },  # Third attempt fails with rate limit
          { status: 200 }   # Fourth attempt succeeds
        )

      expect_any_instance_of(Userlist::Retryable).to receive(:sleep).exactly(3).times
      
      response = subject.post('/events', { foo: :bar })
      expect(response.code).to eq('200')
    end

    it 'gives up after maximum retry attempts' do
      stub_request(:post, 'https://endpoint.test.local/events')
        .to_return(status: 500).times(11) # Initial attempt + 10 retries

      expect_any_instance_of(Userlist::Retryable).to receive(:sleep).exactly(10).times
      
      expect { subject.post('/events', { foo: :bar }) }
        .to raise_error(Userlist::ServerError, "Server error: 500")
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
    it 'should send the payload to the given endpoint' do
      payload = { foo: :bar }

      stub_request(:delete, 'https://endpoint.test.local/events')
        .with(
          body: JSON.dump(payload),
          headers: {
            'Accept' => 'application/json',
            'Content-Type' => 'application/json; charset=UTF-8',
            'Authorization' => 'Push test-push-key'
          }
        )
        .to_return(status: 202)

      subject.delete('/events', payload)
    end
  end
end
