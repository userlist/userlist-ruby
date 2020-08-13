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

  it 'should raise an error when no payload is given' do
    expect { described_class.new(nil) }.to raise_error(Userlist::ArgumentError, /attributes/)
  end

  it 'should raise an error when no user or company is given' do
    payload.delete(:user)
    payload.delete(:company)

    expect { described_class.new(payload) }.to raise_error(Userlist::ArgumentError, /user/)
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

    it 'should exclude the user\'s relationships' do
      expect { subject.relationships }.to raise_error(NoMethodError)
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

    it 'should exclude the company\'s relationships' do
      expect { subject.relationships }.to raise_error(NoMethodError)
    end
  end
end
