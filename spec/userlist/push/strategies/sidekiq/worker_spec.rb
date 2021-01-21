require 'spec_helper'

require 'userlist/push/strategies/sidekiq'
require 'sidekiq/testing'

RSpec.describe Userlist::Push::Strategies::Sidekiq::Worker do
  subject { described_class.new(queue, config) }

  let(:client) { instance_double('Userlist::Push::Client') }

  let(:payload) do
    { foo: :bar }
  end

  let(:expected_payload) do
    { 'foo' => 'bar' }
  end

  around do |example|
    Sidekiq::Testing.inline! do
      example.run
    end
  end

  before do
    allow(Userlist::Push::Client).to receive(:new).and_return(client)
    allow(client).to receive(:post)
  end

  it 'should process the job' do
    expect(client).to receive(:post).with('/events', expected_payload).exactly(5).times
    5.times { described_class.perform_async(:post, '/events', payload) }
  end

  it 'should process requests with and without payload' do
    expect(client).to receive(:post).with('/user', expected_payload).once
    expect(client).to receive(:delete).with('/user/identifier').once

    described_class.perform_async(:post, '/user', payload)
    described_class.perform_async(:delete, '/user/identifier')
  end
end
