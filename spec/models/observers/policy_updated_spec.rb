require 'rails_helper'

describe Observers::PolicyUpdated do
  let(:today) { Time.mktime(2025, 1, 1) }

  context "given a shop policy" do
    let(:policy) do
      instance_double(
        Policy,
        is_shop?: true
      )
    end

    it "does nothing" do
      Observers::PolicyUpdated.notify(policy, today)
    end
  end

  context "given an ivl policy from the current year" do
    let(:policy) do
      instance_double(
        Policy,
        is_shop?: false,
        coverage_year: today.year
      )
    end

    it "does nothing" do
      Observers::PolicyUpdated.notify(policy, today)
    end
  end

  context "given an ivl policy from before 2018" do
    let(:policy) do
      instance_double(
        Policy,
        is_shop?: false,
        coverage_year: 2017
      )
    end

    it "does nothing" do
      Observers::PolicyUpdated.notify(policy, today)
    end
  end

  context "given an ivl policy from a previous policy year, after 1/1/2018" do
    let(:policy_id) { "A POLICY ID" }
    let(:eg_id) { "A POLICY ID" }

    let(:event_broadcaster) do
      instance_double(Amqp::EventBroadcaster)
    end

    let(:policy) do
      instance_double(
        Policy,
        :id => policy_id,
        :eg_id => eg_id,
        is_shop?: false,
        coverage_year: 2018
      )
    end

    before(:each) do
      allow(Amqp::EventBroadcaster).to receive(:with_broadcaster).and_yield(event_broadcaster)
    end

    it "sends the message" do
      expect(event_broadcaster).to receive(:broadcast).with(
        {
          :headers => {
            :policy_id => policy_id,
            :eg_id => eg_id,
          },
          :routing_key => "info.events.policy.federal_reporting_eligibility_updated"
        },
        ""
      )
      Observers::PolicyUpdated.notify(policy, today)
    end
  end
end