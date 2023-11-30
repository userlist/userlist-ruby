require 'spec_helper'

RSpec.describe Userlist::Push::Event do
  let(:payload) do
    {
      name: 'event_name',
      user: 'user-identifier',
      company: 'company-identifier',
      properties: {
        value: '$100.00'
      }
    }
  end

  subject { described_class.new(payload) }

  it 'should raise an error when no payload is given' do
    expect { described_class.new(nil) }.to raise_error(Userlist::ArgumentError, /payload/)
  end

  it 'should raise an error when no name is given' do
    payload.delete(:name)

    expect { described_class.new(payload) }.to raise_error(Userlist::ArgumentError, /name/)
  end

  it 'should be pushable' do
    expect(subject.push?).to be_truthy
  end

  it 'should set the occured_at property' do
    payload.delete(:occured_at)
    event = described_class.new(payload)

    expect(event.occured_at).to be_an_instance_of(Time)
  end

  context 'when a user hash is given' do
    let(:payload) do
      super().merge(
        user: {
          identifier: 'user-identifier',
          email: 'foo@example.com'
        }
      )
    end

    it 'should convert it into a user object' do
      expect(subject.user).to be_kind_of(Userlist::Push::User)
    end

    it 'should include the user\'s properties' do
      expect(subject.user.email).to eq('foo@example.com')
    end

    it 'should be pushable' do
      expect(subject.push?).to be_truthy
    end
  end

  context 'when a company hash is given' do
    let(:payload) do
      super().merge(
        company: {
          identifier: 'company-identifier',
          name: 'Foo, Inc.'
        }
      )
    end

    it 'should convert it into a company object' do
      expect(subject.company).to be_kind_of(Userlist::Push::Company)
    end

    it 'should include the company\'s properties' do
      expect(subject.company.name).to eq('Foo, Inc.')
    end

    it 'should be pushable' do
      expect(subject.push?).to be_truthy
    end
  end

  context 'when there is no user' do
    let(:payload) do
      super().merge(user: nil)
    end

    it 'should be pushable' do
      expect(subject.push?).to be_truthy
    end
  end

  context 'when the is no company' do
    let(:payload) do
      super().merge(company: nil)
    end

    it 'should be pushable' do
      expect(subject.push?).to be_truthy
    end
  end

  context 'when the user and the company are missing' do
    let(:payload) do
      super().merge(user: nil, company: nil)
    end

    it 'should not be pushable' do
      expect(subject.push?).to be_falsey
    end
  end
end
