require 'spec_helper'

RSpec.describe Userlist::Config do
  subject { described_class.new }

  before { ENVCache.start! }
  after { ENVCache.stop! }

  describe 'extending the default configuration' do
    it 'should be possible to add new configuration values' do
      config_class = Class.new(described_class) do
        def default_config
          super.merge(from_class: 'class')
        end
      end

      config_module = Module.new do
        def default_config
          super.merge(from_module: 'module')
        end
      end

      config_class.send(:prepend, config_module)

      config = config_class.new

      expect(config.from_class).to eq('class')
      expect(config.from_module).to eq('module')
    end
  end

  describe '#merge' do
    let(:other_config) do
      { push_key: 'other-key' }
    end

    it 'should return a new configuration object' do
      expect(subject.merge(other_config)).to_not eq(subject)
    end

    it 'should change the given configuration' do
      config = subject.merge(other_config)
      expect(config.push_key).to eq(other_config[:push_key])
    end

    it 'should not change the original configuration' do
      config = subject.merge(other_config)
      expect(subject.push_key).to_not eq(config.push_key)
    end

    it 'should allow merging two configuration objects' do
      config = subject.merge(Userlist::Config.new(other_config))
      expect(config.push_key).to eq(other_config[:push_key])
    end

    it 'should inherit not changed configuration' do
      config = subject.merge(other_config)
      subject.push_strategy = :null
      expect(config.push_key).to eq(other_config[:push_key])
      expect(config.push_strategy).to eq(subject.push_strategy)
    end
  end

  describe '#push_key' do
    it 'should have a default value' do
      expect(subject.push_key).to eq(nil)
    end

    it 'should accept values from the ENV' do
      ENV['USERLIST_PUSH_KEY'] = 'push-key-from-env'
      expect(subject.push_key).to eq('push-key-from-env')
    end

    it 'should accept values via the setter' do
      subject.push_key = 'push-key-from-setter'
      expect(subject.push_key).to eq('push-key-from-setter')
    end
  end

  describe '#push_id' do
    it 'should have a default value' do
      expect(subject.push_id).to eq(nil)
    end

    it 'should accept values from the ENV' do
      ENV['USERLIST_PUSH_ID'] = 'push-id-from-env'
      expect(subject.push_id).to eq('push-id-from-env')
    end

    it 'should accept values via the setter' do
      subject.push_id = 'push-id-from-setter'
      expect(subject.push_id).to eq('push-id-from-setter')
    end
  end

  describe '#push_endpoint' do
    it 'should have a default value' do
      expect(subject.push_endpoint).to eq('https://push.userlist.io/')
    end

    it 'should accept values from the ENV' do
      ENV['USERLIST_PUSH_ENDPOINT'] = 'https://push.from.env/'
      expect(subject.push_endpoint).to eq('https://push.from.env/')
    end

    it 'should accept values via the setter' do
      subject.push_endpoint = 'https://push.from.setter/'
      expect(subject.push_endpoint).to eq('https://push.from.setter/')
    end
  end

  describe '#token_lifetime' do
    it 'should have a default value' do
      expect(subject.token_lifetime).to eq(3600)
    end

    it 'should accept values from the ENV' do
      ENV['USERLIST_TOKEN_LIFETIME'] = '60'
      expect(subject.token_lifetime).to eq(60)
    end

    it 'should accept values via the setter' do
      subject.token_lifetime = 123
      expect(subject.token_lifetime).to eq(123)
    end
  end
end
