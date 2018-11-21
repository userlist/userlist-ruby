require 'spec_helper'

RSpec.describe Userlist do
  it 'has a version number' do
    expect(Userlist::VERSION).not_to be nil
  end

  describe '.config' do
    it 'should return an instance of Userlist::Config' do
      expect(described_class.config).to be_instance_of(Userlist::Config)
    end
  end

  describe '.logger' do
    it 'should return an instance of Logger' do
      expect(described_class.logger).to be_instance_of(Logger)
    end
  end
end
