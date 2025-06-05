require 'spec_helper'

RSpec.describe Userlist::Push::Serializer do
  subject { described_class.new(context: :push) }

  let(:user) do
    Userlist::Push::User.new(
      identifier: 'user-identifier',
      email: 'foo@example.com',
      signed_up_at: nil
    )
  end

  let(:company) do
    Userlist::Push::Company.new(
      identifier: 'company-identifier',
      name: 'Example, Inc.',
      signed_up_at: nil
    )
  end

  let(:relationship) do
    Userlist::Push::Relationship.new(
      user: user,
      company: company,
      properties: {
        role: 'admin'
      }
    )
  end

  let(:event) do
    Userlist::Push::Event.new(
      user: user,
      company: company,
      name: 'example_event',
      occurred_at: Time.now,
      properties: {
        null: nil,
        empty: [],
        value: 'foo'
      }
    )
  end

  before do
    user&.relationships = [relationship]
    company&.relationships = [relationship]
  end

  describe '#serialize' do
    let(:payload) { subject.serialize(resource) }

    context 'when serializing the user' do
      let(:resource) { user }

      it 'should return the correct payload' do
        expect(payload).to eq(
          identifier: 'user-identifier',
          email: 'foo@example.com',
          signed_up_at: nil,
          relationships: [
            {
              user: 'user-identifier',
              company: {
                identifier: 'company-identifier',
                name: 'Example, Inc.',
                signed_up_at: nil
              },
              properties: {
                role: 'admin'
              }
            }
          ]
        )
      end

      context 'when serializing the user is not allowed' do
        context 'when the context is push' do
          subject { described_class.new(context: :push) }

          before do
            expect_any_instance_of(Userlist::Push::User).to receive(:push?).and_return(false)
          end

          it 'should return no payload' do
            expect(payload).to_not be
          end
        end

        context 'when the context is delete' do
          subject { described_class.new(context: :delete) }

          before do
            expect_any_instance_of(Userlist::Push::User).to receive(:delete?).and_return(false)
          end

          it 'should return no payload' do
            expect(payload).to_not be
          end
        end

        context 'when the context is unsupported' do
          subject { described_class.new(context: :unsupported) }

          it 'should return no payload' do
            expect(payload).to_not be
          end
        end
      end

      context 'when serializing the company is not allowed' do
        before do
          allow_any_instance_of(Userlist::Push::Company).to receive(:push?).and_return(false)
        end

        it 'should return the correct payload' do
          expect(payload).to eq(
            identifier: 'user-identifier',
            email: 'foo@example.com',
            signed_up_at: nil
          )
        end
      end

      context 'when serializing the relationship is not allowed' do
        before do
          allow_any_instance_of(Userlist::Push::Relationship).to receive(:push?).and_return(false)
        end

        it 'should return the correct payload' do
          expect(payload).to eq(
            identifier: 'user-identifier',
            email: 'foo@example.com',
            signed_up_at: nil
          )
        end
      end
    end

    context 'when serializing the company' do
      let(:resource) { company }

      it 'should return the correct payload' do
        expect(payload).to eq(
          identifier: 'company-identifier',
          name: 'Example, Inc.',
          signed_up_at: nil,
          relationships: [
            {
              company: 'company-identifier',
              user: {
                identifier: 'user-identifier',
                email: 'foo@example.com',
                signed_up_at: nil
              },
              properties: {
                role: 'admin'
              }
            }
          ]
        )
      end

      context 'when serializing the user is not allowed' do
        before do
          allow_any_instance_of(Userlist::Push::User).to receive(:push?).and_return(false)
        end

        it 'should return the correct payload' do
          expect(payload).to eq(
            identifier: 'company-identifier',
            name: 'Example, Inc.',
            signed_up_at: nil
          )
        end
      end

      context 'when serializing the company is not allowed' do
        before do
          allow_any_instance_of(Userlist::Push::Company).to receive(:push?).and_return(false)
        end

        it 'should return no payload' do
          expect(payload).to_not be
        end
      end

      context 'when serializing the relationship is not allowed' do
        before do
          allow_any_instance_of(Userlist::Push::Relationship).to receive(:push?).and_return(false)
        end

        it 'should return the correct payload' do
          expect(payload).to eq(
            identifier: 'company-identifier',
            name: 'Example, Inc.',
            signed_up_at: nil
          )
        end
      end
    end

    context 'when serializing the relationship' do
      let(:resource) { relationship }

      it 'should return the correct payload' do
        expect(payload).to eq(
          user: {
            identifier: 'user-identifier',
            email: 'foo@example.com',
            signed_up_at: nil
          },
          company: {
            identifier: 'company-identifier',
            name: 'Example, Inc.',
            signed_up_at: nil
          },
          properties: {
            role: 'admin'
          }
        )
      end

      context 'when serializing the user is not allowed' do
        before do
          allow_any_instance_of(Userlist::Push::User).to receive(:push?).and_return(false)
        end

        it 'should return no payload' do
          expect(payload).to_not be
        end
      end

      context 'when serializing the company is not allowed' do
        before do
          allow_any_instance_of(Userlist::Push::Company).to receive(:push?).and_return(false)
        end

        it 'should return no payload' do
          expect(payload).to_not be
        end
      end
    end

    context 'when serializing the event' do
      let(:resource) { event }

      it 'should return the correct payload' do
        expect(payload).to eq(
          name: 'example_event',
          occurred_at: event.occurred_at,
          user: {
            identifier: 'user-identifier',
            email: 'foo@example.com',
            signed_up_at: nil,
            relationships: [
              {
                user: 'user-identifier',
                company: {
                  identifier: 'company-identifier',
                  name: 'Example, Inc.',
                  signed_up_at: nil
                },
                properties: {
                  role: 'admin'
                }
              }
            ]
          },
          company: 'company-identifier',
          properties: {
            null: nil,
            empty: [],
            value: 'foo'
          }
        )
      end

      context 'when serializing the user is not allowed' do
        before do
          allow_any_instance_of(Userlist::Push::User).to receive(:push?).and_return(false)
        end

        it 'should return no payload' do
          expect(payload).to_not be
        end
      end

      context 'when serializing the company is not allowed' do
        before do
          allow_any_instance_of(Userlist::Push::Company).to receive(:push?).and_return(false)
        end

        it 'should return no payload' do
          expect(payload).to_not be
        end
      end

      context 'when there is no occurred_at given' do
        let(:event) do
          Userlist::Push::Event.new(
            user: user,
            name: 'example_event'
          )
        end

        it 'should set a default occurred_at' do
          expect(payload[:occurred_at]).to be_within(1).of(Time.now)
        end
      end
    end
  end
end
