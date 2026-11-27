require 'spec_helper'
require 'jwt'

RSpec.describe Userlist::Token do
  describe '.generate' do
    let(:token) { described_class.generate(payload, config) }
    let(:config) do
      {
        push_key: push_key,
        push_id: push_id
      }
    end

    let(:payload) { identifier }
    let(:identifier) { 'userlist-identifier' }
    let(:push_id) { 'push-id' }
    let(:push_key) { 'push-key' }

    context 'when no push key is configured' do
      let(:push_key) { nil }

      it 'should raise an Userlist::ArgumentError' do
        expect { token }.to raise_error(Userlist::ConfigurationError, /push_key/)
      end
    end

    context 'when no push id is configured' do
      let(:push_id) { nil }

      it 'should raise an Userlist::ArgumentError' do
        expect { token }.to raise_error(Userlist::ConfigurationError, /push_id/)
      end
    end

    context 'when no identifier is given' do
      let(:identifier) { nil }

      it 'should raise an Userlist::ArgumentError' do
        expect { token }.to raise_error(Userlist::ArgumentError, /identifier/)
      end
    end

    context 'when a user is given' do
      let(:payload) { Userlist::Push::User.from_payload(identifier) }

      it 'should generate a valid JSON web token' do
        expect { JWT.decode(token, push_key, true, algorithm: 'HS256') }
          .to_not raise_error
      end
    end

    context 'when a user hash is given' do
      let(:payload) { { identifier: identifier } }

      it 'should generate a valid JSON web token' do
        expect { JWT.decode(token, push_key, true, algorithm: 'HS256') }
          .to_not raise_error
      end
    end

    context 'when an identifier is given' do
      let(:payload) { identifier }

      it 'should generate a valid JSON web token' do
        expect { JWT.decode(token, push_key, true, algorithm: 'HS256') }
          .to_not raise_error
      end
    end

    it 'should encode each part like unpadded urlsafe Base64' do
      require 'base64'

      parts = token.split('.')
      expect(parts.size).to eq(3)

      parts.each do |part|
        decoded = part.tr('-_', '+/').ljust((part.size + 3) / 4 * 4, '=').unpack1('m0')
        expect(part).to eq(Base64.urlsafe_encode64(decoded).delete('='))
      end
    end

    it 'should generate a token when nothing has loaded the base64 library' do
      require 'open3'
      require 'rbconfig'

      script = <<~RUBY
        require 'userlist'
        print Userlist::Token.generate('#{identifier}', push_key: '#{push_key}', push_id: '#{push_id}')
      RUBY
      lib = File.expand_path('../../lib', __dir__)
      output, error, status = Open3.capture3(RbConfig.ruby, '-I', lib, '-e', script)

      expect(status).to be_success, error
      expect { JWT.decode(output, push_key, true, algorithm: 'HS256') }.to_not raise_error
    end
  end
end
