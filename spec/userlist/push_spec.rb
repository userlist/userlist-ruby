require 'spec_helper'

RSpec.describe Userlist::Push do
  subject { described_class.new(push_strategy: strategy) }

  let(:strategy) { instance_double('Userlist::Push::Strategies::Direct') }

  describe 'delegated class methods' do
    let(:push_instance) { instance_double(described_class) }

    before do
      allow(described_class).to receive(:new).and_return(push_instance)
    end

    after do
      described_class.instance_variable_set(:@default_push_instance, nil)
    end

    [:event, :track, :user, :identify, :company].each do |method|
      describe ".#{method}" do
        let(:args) { [{ foo: 'bar' }] }

        it 'should forward the method call to the default push instance' do
          expect(push_instance).to receive(method).with(*args)
          described_class.send(method, *args)
        end
      end
    end

    [:users, :events, :companies, :relationships].each do |method|
      describe ".#{method}" do
        it 'should forward the method call to the default push instance' do
          expect(push_instance).to receive(method)
          described_class.send(method)
        end
      end
    end
  end

  describe '#users' do
    let(:relation) { subject.users }

    it 'should return a relation' do
      expect(relation).to be_an_instance_of(Userlist::Push::Relation)
      expect(relation.type).to eq(Userlist::Push::User)
    end

    it 'should support the push operation' do
      expect(relation).to be_kind_of(Userlist::Push::Operations::Push::ClassMethods)
    end

    it 'should support the delete operation' do
      expect(relation).to be_kind_of(Userlist::Push::Operations::Delete::ClassMethods)
    end
  end

  describe '#companies' do
    let(:relation) { subject.companies }

    it 'should return a relation' do
      expect(relation).to be_an_instance_of(Userlist::Push::Relation)
      expect(relation.type).to eq(Userlist::Push::Company)
    end

    it 'should support the push operation' do
      expect(relation).to be_kind_of(Userlist::Push::Operations::Push::ClassMethods)
    end

    it 'should support the delete operation' do
      expect(relation).to be_kind_of(Userlist::Push::Operations::Delete::ClassMethods)
    end
  end

  describe '#relationships' do
    let(:relation) { subject.relationships }

    it 'should return a relation' do
      expect(relation).to be_an_instance_of(Userlist::Push::Relation)
      expect(relation.type).to eq(Userlist::Push::Relationship)
    end

    it 'should support the push operation' do
      expect(relation).to be_kind_of(Userlist::Push::Operations::Push::ClassMethods)
    end
  end

  describe '#events' do
    let(:relation) { subject.events }

    it 'should return a relation' do
      expect(relation).to be_an_instance_of(Userlist::Push::Relation)
      expect(relation.type).to eq(Userlist::Push::Event)
    end

    it 'should support the push operation' do
      expect(relation).to be_kind_of(Userlist::Push::Operations::Push::ClassMethods)
    end
  end

  describe '#event' do
    let(:payload) do
      {
        name: 'event_name',
        user: 'identifier',
        properties: {
          value: '$100.00'
        }
      }
    end

    let(:relation) { subject.events }

    it 'should delegate the call to the relation\'s push method' do
      expect(relation).to receive(:push).with(payload)
      subject.event(payload)
    end

    it 'should be aliased as #track' do
      expect(subject.method(:track)).to eq(subject.method(:event))
    end
  end

  describe '#user' do
    let(:payload) do
      {
        identifier: 'identifier',
        properties: {
          first_name: 'John',
          last_name: 'Doe'
        }
      }
    end

    let(:relation) { subject.users }

    it 'should delegate the call to the relation\'s push method' do
      expect(relation).to receive(:push).with(payload)
      subject.user(payload)
    end

    it 'should be aliased as #identify' do
      expect(subject.method(:identify)).to eq(subject.method(:user))
    end
  end

  describe '#company' do
    let(:payload) do
      {
        identifier: 'identifier',
        properties: {
          name: 'John Doe Co.'
        }
      }
    end

    let(:relation) { subject.companies }

    it 'should delegate the call to the relation\'s push method' do
      expect(relation).to receive(:push).with(payload)
      subject.company(payload)
    end
  end

  describe '#messages' do
    let(:relation) { subject.messages }

    it 'should return a relation' do
      expect(relation).to be_an_instance_of(Userlist::Push::Relation)
      expect(relation.type).to eq(Userlist::Push::Message)
    end

    it 'should support the push operation' do
      expect(relation).to be_kind_of(Userlist::Push::Operations::Push::ClassMethods)
    end
  end

  describe '#message' do
    let(:payload) do
      {
        template: 'template-identifier',
        user: 'user-identifier',
        properties: {
          value: '$100.00'
        }
      }
    end

    let(:relation) { subject.messages }

    it 'should delegate the call to the relation\'s push method' do
      expect(relation).to receive(:push).with(payload)
      subject.message(payload)
    end
  end
end
