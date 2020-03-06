require 'spec_helper'

RSpec.describe Userlist::Push::Company do
  let(:payload) do
    {
      identifier: 'identifier',
      properties: {
        name: 'John Doe Co.'
      }
    }
  end

  it 'should raise an error when no payload is given' do
    expect { described_class.new(nil) }.to raise_error(Userlist::ArgumentError, /attributes/)
  end

  it 'should raise an error when no identifier is given' do
    payload.delete(:identifier)

    expect { described_class.new(payload) }.to raise_error(Userlist::ArgumentError, /identifier/)
  end
end
