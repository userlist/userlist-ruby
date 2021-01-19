require 'spec_helper'

RSpec.describe Userlist::Push::Company do
  let(:payload) do
    {
      identifier: 'company-identifier',
      properties: {
        name: 'John Doe Co.'
      }
    }
  end

  it 'should raise an error when no payload is given' do
    expect { described_class.new(nil) }.to raise_error(Userlist::ArgumentError, /payload/)
  end

  it 'should raise an error when no identifier is given' do
    payload.delete(:identifier)

    expect { described_class.new(payload) }.to raise_error(Userlist::ArgumentError, /identifier/)
  end

  context 'when given a list of relationships' do
    subject { described_class.new(payload) }

    let(:payload) do
      super().merge(
        relationships: [
          {
            user: 'user-identifier',
            company: 'company-identifier',
            properties: {
              role: 'owner'
            }
          },
          {
            user: 'other-user-identifier',
            company: 'company-identifier',
            properties: {
              role: 'user'
            }
          }
        ]
      )
    end

    it 'should convert the items into relationship objects' do
      expect(subject.relationships).to match(
        [
          an_instance_of(Userlist::Push::Relationship),
          an_instance_of(Userlist::Push::Relationship)
        ]
      )
    end

    it 'should include the relationships\'s properties' do
      expect(subject.relationships.map(&:properties)).to match(
        [
          { role: 'owner' },
          { role: 'user' }
        ]
      )
    end
  end
end
