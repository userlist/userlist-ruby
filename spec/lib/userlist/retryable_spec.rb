require 'spec_helper'

RSpec.describe Userlist::Retryable do
  subject { described_class.new(&:!) }

  before do
    allow_any_instance_of(described_class).to receive(:sleep)
  end

  it 'should not retry when the attempt is successful' do
    attempts = 0

    subject.attempt do
      attempts += 1
      true
    end

    expect(attempts).to eq(1)
  end

  it 'should retry until the attempt is successful' do
    attempts = 0

    subject.attempt do
      attempts += 1
      attempts > 5
    end

    expect(attempts).to eq(6)
  end

  it 'should retry a maximum number of times if the attempt is always unsuccessful' do
    attempts = 0

    subject.attempt do
      attempts += 1
      false
    end

    expect(attempts).to eq(11)
  end

  it 'should wait between the attempts' do
    expect(subject).to receive(:sleep).exactly(10).times

    subject.attempt { false }
  end
end
