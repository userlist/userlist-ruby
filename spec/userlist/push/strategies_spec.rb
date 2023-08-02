require 'spec_helper'

require 'userlist/push/strategies/direct'

RSpec.describe Userlist::Push::Strategies do
  describe '.strategy_for' do
    let(:config) do
      { push_endpoint: 'http://localhost' }
    end

    it 'should work with a Symbol' do
      strategy = described_class.strategy_for(:direct, config)
      expect(strategy).to be_an_instance_of(Userlist::Push::Strategies::Direct)
    end

    it 'should work with a String' do
      strategy = described_class.strategy_for('direct', config)
      expect(strategy).to be_an_instance_of(Userlist::Push::Strategies::Direct)
    end

    it 'should work with a Class' do
      strategy = described_class.strategy_for(Userlist::Push::Strategies::Direct, config)
      expect(strategy).to be_an_instance_of(Userlist::Push::Strategies::Direct)
    end

    it 'should work with an Object' do
      strategy = described_class.strategy_for(Userlist::Push::Strategies::Direct.new(config))
      expect(strategy).to be_an_instance_of(Userlist::Push::Strategies::Direct)
    end

    it 'should work with an camelized string' do
      strategy = described_class.strategy_for('active_job', config)
      expect(strategy).to be_an_instance_of(Userlist::Push::Strategies::ActiveJob)
    end

    it 'should require the given strategy' do
      expect(subject).to receive(:require).with('userlist/push/strategies/null').and_call_original
      strategy = described_class.strategy_for(:null, config)
      expect(strategy).to be_an_instance_of(Userlist::Push::Strategies::Null)
    end

    it 'should not require the given strategy when it is already loaded' do
      expect(subject).to_not receive(:require).with('userlist/push/strategies/direct')
      described_class.strategy_for(:direct, config)
    end

    it 'should pass along the configuration' do
      expect(Userlist::Push::Strategies::Direct)
        .to receive(:new).with(config).and_call_original

      described_class.strategy_for(:direct, config)
    end
  end
end
