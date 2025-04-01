require 'spec_helper'
require 'mail'

RSpec.describe Userlist::DeliveryMethod do
  let(:push_client) { instance_double(Userlist::Push) }
  let(:messages) { instance_double('Messages') }
  let(:config) { { push_key: 'test-key' } }

  before do
    allow(Userlist::Push).to receive(:new).with(config).and_return(push_client)
    allow(push_client).to receive(:messages).and_return(messages)
    allow(messages).to receive(:push)
  end

  describe '#deliver!' do
    let(:delivery_method) { described_class.new(config) }

    context 'with plain text email' do
      let(:mail) do
        Mail.new(
          to: 'Example User <user@example.com>',
          from: 'Example Sender <sender@example.com>',
          subject: 'Test Subject',
          body: 'Hello world'
        )
      end

      it 'delivers the message correctly' do
        expected_payload = {
          to: ['user@example.com'],
          from: ['sender@example.com'],
          subject: 'Test Subject',
          body: { type: :text, content: 'Hello world' },
          theme: nil
        }

        expect(messages).to receive(:push).with(expected_payload)
        delivery_method.deliver!(mail)
      end
    end

    context 'with HTML email' do
      let(:mail) do
        Mail.new do
          to 'user@example.com'
          from 'sender@example.com'
          subject 'Test Subject'

          html_part do
            content_type 'text/html'
            body '<p>Hello world</p>'
          end
        end
      end

      it 'delivers the message correctly' do
        expected_payload = {
          to: ['user@example.com'],
          from: ['sender@example.com'],
          subject: 'Test Subject',
          body: { type: :html, content: '<p>Hello world</p>' },
          theme: nil
        }

        expect(messages).to receive(:push).with(expected_payload)
        delivery_method.deliver!(mail)
      end
    end

    context 'with multipart email' do
      let(:mail) do
        Mail.new do
          to 'user@example.com'
          from 'sender@example.com'
          subject 'Test Subject'

          text_part do
            body 'Hello world'
          end

          html_part do
            content_type 'text/html'
            body '<p>Hello world</p>'
          end
        end
      end

      it 'delivers the message correctly' do
        expected_payload = {
          to: ['user@example.com'],
          from: ['sender@example.com'],
          subject: 'Test Subject',
          body: {
            type: :multipart,
            content: [
              { type: :text, content: 'Hello world' },
              { type: :html, content: '<p>Hello world</p>' }
            ]
          },
          theme: nil
        }

        expect(messages).to receive(:push).with(expected_payload)
        delivery_method.deliver!(mail)
      end
    end
  end
end
