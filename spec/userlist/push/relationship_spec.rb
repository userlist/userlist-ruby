require 'spec_helper'

RSpec.describe Userlist::Push::Relationship do
  let(:payload) do
    {
      user: 'user-identifier',
      company: 'company-identifier',
      properties: {
        first_name: 'John',
        last_name: 'Doe'
      }
    }
  end

  subject { described_class.new(payload) }

  it 'should raise an error when no payload is given' do
    expect { described_class.new(nil) }.to raise_error(Userlist::ArgumentError, /payload/)
  end

  context 'when a user hash is given' do
    subject { described_class.new(payload) }

    let(:payload) do
      super().merge(
        user: {
          identifier: 'user-identifier',
          email: 'foo@example.com',
          relationships: [
            { company: 'company-identifier' }
          ]
        }
      )
    end

    it 'should convert it into a user object' do
      expect(subject.user).to be_kind_of(Userlist::Push::User)
    end

    it 'should include the user\'s properties' do
      expect(subject.user.email).to eq('foo@example.com')
    end
  end

  context 'when a company hash is given' do
    subject { described_class.new(payload) }

    let(:payload) do
      super().merge(
        company: {
          identifier: 'company-identifier',
          name: 'Foo, Inc.',
          relationships: [
            { user: 'user-identifier' }
          ]
        }
      )
    end

    it 'should convert it into a company object' do
      expect(subject.company).to be_kind_of(Userlist::Push::Company)
    end

    it 'should include the company\'s properties' do
      expect(subject.company.name).to eq('Foo, Inc.')
    end
  end

  describe '#url' do
    it 'should combine the endpoint, the user identifier, and the company identifier' do
      expect(subject.url).to eq('/relationships/user-identifier/company-identifier')
    end

    context 'when no user is given' do
      let(:payload) { super().merge(user: nil) }

      it 'should raise an error message' do
        expect { subject.url }.to raise_error(Userlist::Error, /user/)
      end
    end

    context 'when no company is given' do
      let(:payload) { super().merge(company: nil) }

      it 'should raise an error message' do
        expect { subject.url }.to raise_error(Userlist::Error, /company/)
      end
    end
  end
end
