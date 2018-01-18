require 'spec_helper'

RSpec.describe Userlist::Push do
  subject { described_class.new }

  let(:client) { instance_double('Userlist::Push::Client') }

  before do
    allow(Userlist::Push::Client).to receive(:new).and_return(client)
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

    it 'should raise an error when no name is given' do
      payload.delete(:name)

      expect { subject.event(payload) }.to raise_error(ArgumentError, /name/)
    end

    it 'should raise an error when no user is given' do
      payload.delete(:user)

      expect { subject.event(payload) }.to raise_error(ArgumentError, /user/)
    end

    it 'should send the payload to the endpoint' do
      expect(client).to receive(:post).with('/events', payload)

      subject.event(payload)
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

    it 'should raise an error when no identifier is given' do
      payload.delete(:identifier)

      expect { subject.user }.to raise_error(ArgumentError, /identifier/)
    end

    it 'should send the payload to the endpoint' do
      expect(client).to receive(:post).with('/users', payload)

      subject.user(payload)
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

    it 'should raise an error when no identifier is given' do
      payload.delete(:identifier)

      expect { subject.company }.to raise_error(ArgumentError, /identifier/)
    end

    it 'should send the payload to the endpoint' do
      expect(client).to receive(:post).with('/companies', payload)

      subject.company(payload)
    end
  end
end
