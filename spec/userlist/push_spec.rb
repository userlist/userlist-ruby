require 'spec_helper'

RSpec.describe Userlist::Push do
  subject { described_class.new(push_strategy: strategy) }

  let(:strategy) { instance_double('Userlist::Push::Strategies::Direct') }

  [:event, :track, :user, :identify, :company].each do |method|
    describe ".#{method}" do
      let(:push_instance) { instance_double(described_class) }
      let(:args) { [{ foo: 'bar' }] }

      before do
        allow(described_class).to receive(:new).and_return(push_instance)
      end

      after do
        described_class.instance_variable_set(:@default_push_instance, nil)
      end

      it 'should forward the method call to the default push instance' do
        expect(push_instance).to receive(method).with(*args)
        described_class.send(method, *args)
      end
    end
  end

  describe '#event' do
    let(:payload) do
      {
        name: 'event_name',
        user: 'identifier',
        properties: {
          value: '$100.00'
        }
      }
    end

    it 'should raise an error when no payload is given' do
      expect { subject.event(nil).to raise_error(Argument, /payload/) }
    end

    it 'should raise an error when no name is given' do
      payload.delete(:name)

      expect { subject.event(payload) }.to raise_error(ArgumentError, /name/)
    end

    it 'should raise an error when no user is given' do
      payload.delete(:user)

      expect { subject.event(payload) }.to raise_error(ArgumentError, /user/)
    end

    it 'should send the payload to the endpoint' do
      expect(strategy).to receive(:call).with(:post, '/events', payload)

      subject.event(payload)
    end

    it 'should set the occured_at property' do
      expect(strategy).to receive(:call)
        .with(:post, '/events', hash_including(occured_at: an_instance_of(Time)))

      subject.event(payload)
    end

    it 'should be aliased as #track' do
      expect(subject.method(:track)).to eq(subject.method(:event))
    end
  end

  describe '#user' do
    let(:payload) do
      {
        identifier: 'identifier',
        properties: {
          first_name: 'John',
          last_name: 'Doe'
        }
      }
    end

    it 'should raise an error when no payload is given' do
      expect { subject.user(nil).to raise_error(Argument, /payload/) }
    end

    it 'should raise an error when no identifier is given' do
      payload.delete(:identifier)

      expect { subject.user }.to raise_error(ArgumentError, /identifier/)
    end

    it 'should send the payload to the endpoint' do
      expect(strategy).to receive(:call).with(:post, '/users', payload)

      subject.user(payload)
    end

    it 'should be aliased as #identify' do
      expect(subject.method(:identify)).to eq(subject.method(:user))
    end
  end

  describe '#company' do
    let(:payload) do
      {
        identifier: 'identifier',
        properties: {
          name: 'John Doe Co.'
        }
      }
    end

    it 'should raise an error when no payload is given' do
      expect { subject.company(nil).to raise_error(Argument, /payload/) }
    end

    it 'should raise an error when no identifier is given' do
      payload.delete(:identifier)

      expect { subject.company }.to raise_error(ArgumentError, /identifier/)
    end

    it 'should send the payload to the endpoint' do
      expect(strategy).to receive(:call).with(:post, '/companies', payload)

      subject.company(payload)
    end
  end
end
