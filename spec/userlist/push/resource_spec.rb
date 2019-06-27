require 'spec_helper'

RSpec.describe Userlist::Push::Resource do
  let(:dummy_resource) do
    Class.new(described_class) do
      def self.name
        'Userlist::Push::Object'
      end
    end
  end

  let(:attributes) do
    {
      identifier: 'object-id',
      foo: 'bar'
    }
  end

  subject { dummy_resource.new(attributes) }

  describe '.resource_name' do
    it 'should drop the namespace' do
      expect(dummy_resource.resource_name).to eq('Object')
    end
  end

  describe '.endpoint' do
    it 'should infer the url from the name' do
      expect(dummy_resource.endpoint).to eq('/objects')
    end
  end

  describe 'additional methods' do
    context 'when there is an corresponding attribute' do
      it 'should return the attribute\'s value' do
        expect(subject.foo).to eq('bar')
      end
    end

    context 'when the attribute is not available' do
      it 'should raise a NoMethodError' do
        expect { subject.bar }.to raise_error(NoMethodError)
      end
    end

    context 'when trying to set an attribute' do
      it 'should set the attribute' do
        subject.foo = 'bar'
        expect(subject.foo).to eq('bar')
      end
    end
  end
end
