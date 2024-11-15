require 'spec_helper'

RSpec.describe Userlist::Retryable do
  subject { described_class.new { true } }

  before do
    allow_any_instance_of(described_class).to receive(:sleep)
  end

  it 'should not retry when the attempt is successful' do
    attempts = 0

    subject.attempt do
      attempts += 1
    end

    expect(attempts).to eq(1)
  end

  it 'should retry until the attempt is successful' do
    attempts = 0

    subject.attempt do
      attempts += 1

      raise Userlist::Error unless attempts > 5
    end

    expect(attempts).to eq(6)
  end

  it 'should retry a maximum number of times if the attempt is always unsuccessful' do
    attempts = 0

    subject.attempt do
      attempts += 1

      raise Userlist::Error
    end

    expect(attempts).to eq(11)
  end

  it 'should wait between the attempts' do
    expect(subject).to receive(:sleep).exactly(10).times

    subject.attempt { raise Userlist::Error }
  end
end
