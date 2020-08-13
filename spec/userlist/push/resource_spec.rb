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

  let(:config) { Userlist.config }

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

  describe '.from_payload' do
    it 'should create a new instance of the resource' do
      resource = described_class.from_payload(attributes)
      expect(resource).to be_kind_of(described_class)
    end

    it 'should set the given attributes' do
      resource = described_class.from_payload(attributes)
      expect(resource.attributes).to match(attributes)
    end

    it 'should convert strings into simple payloads' do
      resource = described_class.from_payload('identifier')
      expect(resource.attributes).to match({ identifier: 'identifier' })
    end

    context 'when the only option is given' do
      let(:resource) { described_class.from_payload(attributes, config, only: [:identifier]) }

      it 'should set the specified attributes' do
        expect(resource.to_hash).to match(identifier: 'object-id')
      end

      it 'should not set other attributes' do
        expect(resource.to_hash).to_not match(foo: 'bar')
      end
    end

    context 'when the except option is given' do
      let(:resource) { described_class.from_payload(attributes, config, except: [:foo]) }

      it 'should not set the specified attributes' do
        expect(resource.to_hash).to_not match(foo: 'bar')
      end

      it 'should set other attributes' do
        expect(resource.to_hash).to match(identifier: 'object-id')
      end
    end
  end

  describe '#url' do
    it 'should combine the endpoint and the identifier' do
      expect(subject.url).to eq('/objects/object-id')
    end
  end

  describe '#config' do
    it 'should return the given config' do
      config = Userlist.config.merge(push_strategy: :null)
      resource = described_class.new({}, config)
      expect(resource.config).to eq(config)
    end

    it 'should return the default config if none was given' do
      resource = described_class.new({})
      expect(resource.config).to eq(Userlist.config)
    end
  end

  describe '#to_hash' do
    it 'should return the resource\'s attributes' do
      expect(subject.to_hash).to eq(
        identifier: 'object-id',
        foo: 'bar'
      )
    end

    it 'should be aliased as #to_h' do
      expect(subject.to_hash).to eq(subject.to_h)
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
