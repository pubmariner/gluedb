require 'rails_helper'

describe Policies::CreatePolicy do
  let(:listener) { double(:fail => nil, :policy_already_exists => nil, :plan_not_found => nil) }
  let(:request) { {:enrollment_group_id => enrollment_group_id, :hios_id => hios_id, :plan_year => plan_year} }
  let(:hios_id) { "DLJKFKLSDJEF" }
  let(:enrollment_group_id) { "LSJKDKLFJEF" }
  let(:existing_policy) { nil }
  let(:plan_year) { "2015" }
  let(:plan) { double }

  subject { Policies::CreatePolicy.new }

  before :each do
    allow(Policy).to receive(:find_for_group_and_hios).with(
      enrollment_group_id,
      hios_id
    ).and_return(existing_policy)
    allow(Plan).to receive(:find_by_hios_id_and_year).with(
      hios_id,
      plan_year
    ).and_return(plan)
  end

  describe "with an already existing policy" do
    let(:existing_policy) { double }

    it "should notify the listener of failure" do
      expect(listener).to receive(:policy_already_exists).with({
        :enrollment_group_id => enrollment_group_id,
        :hios_id => hios_id
      })
      expect(subject.validate(request, listener)).to be_falsey
    end
  end

  describe "with a plan that doesn't exist" do
    let(:plan) { nil }

    it "should notify the listener of failure" do
      expect(listener).to receive(:plan_not_found).with({
        :hios_id => hios_id,
        :plan_year => plan_year
      })
      expect(subject.validate(request, listener)).to be_falsey
    end
  end

  describe "with a broker that doesn't exist" do
    let(:npn) { "andskflnsdf" }
    let(:request) { {:enrollment_group_id => enrollment_group_id, :hios_id => hios_id, :plan_year => plan_year, :broker_npn => npn} }

    before(:each) do
      allow(Broker).to receive(:find_by_npn).with(npn).and_return(nil)
    end

    it "should notify the listener of failure" do
      expect(listener).to receive(:broker_not_found).with({:npn => npn})
      expect(subject.validate(request, listener)).to be_falsey
    end
  end
end
