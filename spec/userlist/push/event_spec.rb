require 'spec_helper'

RSpec.describe Userlist::Push::Event do
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
    expect { described_class.new(nil) }.to raise_error(Userlist::ArgumentError, /payload/)
  end

  it 'should raise an error when no name is given' do
    payload.delete(:name)

    expect { described_class.new(payload) }.to raise_error(Userlist::ArgumentError, /name/)
  end

  it 'should set the occured_at property' do
    payload.delete(:occured_at)
    event = described_class.new(payload)

    expect(event.occured_at).to be_an_instance_of(Time)
  end
end
