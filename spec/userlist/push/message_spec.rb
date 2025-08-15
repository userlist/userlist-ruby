require 'spec_helper'

RSpec.describe Userlist::Push::Message do
  let(:payload) do
    {
      template: 'template-identifier',
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

  it 'should be pushable' do
    expect(subject.push?).to be_truthy
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

    it 'should be pushable' do
      expect(subject.push?).to be_truthy
    end
  end

  context 'when a company hash is given' do
    let(:payload) do
      super().merge(
        company: {
          identifier: 'company-identifier',
          name: 'Example Company'
        }
      )
    end

    it 'should convert it into a company object' do
      expect(subject.company).to be_kind_of(Userlist::Push::Company)
    end

    it 'should be pushable' do
      expect(subject.push?).to be_truthy
    end
  end
end
