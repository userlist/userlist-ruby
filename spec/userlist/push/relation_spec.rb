require 'spec_helper'

RSpec.describe Userlist::Push::Relation do
  let(:scope) { double(:scope) }
  let(:resource_type) { double(:resource_type, endpoint: '/messages') }
  let(:operations) { [Userlist::Push::Operations::Create, Userlist::Push::Operations::Delete] }

  subject { described_class.new(scope, resource_type, operations) }

  describe '.new' do
    it 'should require a scope' do
      expect { described_class.new }.to raise_error(ArgumentError)
    end

    it 'should require a resource type' do
      expect { described_class.new(scope) }.to raise_error(ArgumentError)
    end

    it 'should not include any operations by default' do
      relation = described_class.new(scope, resource_type)
      expect(relation.singleton_class.ancestors)
        .to_not include(*operations.map { |operation| operation::ClassMethods })
    end

    it 'should include the given operations' do
      expect(subject.singleton_class.ancestors)
        .to include(*operations.map { |operation| operation::ClassMethods })
    end
  end
end
