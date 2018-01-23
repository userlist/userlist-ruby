require 'spec_helper'

RSpec.describe Userlist::Push::Strategies do
  describe '.strategy_for' do
    let(:config) do
      { push_endpoint: 'http://localhost' }
    end

    before do
      expect(Userlist::Push::Strategies::Direct)
        .to receive(:new).with(config).and_call_original
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
  end
end
