require "rails_helper"

describe Listeners::ReportEligibilityUpdatedReducerListener do
  let(:first_policy) { instance_double('Policy', id: 1)}
  let(:second_policy) { instance_double('Policy', id: 2) }
  let(:worker_id) { 1 }
  let(:event_time) { Time.now - 1.week }
  let!(:reporting_eligibility_updated_queued_record) do
    PolicyEvents::ReportingEligibilityUpdated.create!(
      policy_id: first_policy.id,
      status: 'queued',
      event_time: event_time,
      worker_id: worker_id.to_s
    )
  end
  let!(:reporting_eligibility_updated_processing_record) do
    PolicyEvents::ReportingEligibilityUpdated.create!(
      policy_id: second_policy.id,
      status: 'processing',
      event_time: event_time,
      worker_id: worker_id.to_s
    )
  end

  before :each do
    allow(Process).to receive(:pid).and_return(worker_id.to_s)
  end

  it "updates from queued to processing and processing to processed" do
    PolicyEvents::ReportingEligibilityUpdated.events_for_processing(event_time)
    expect(PolicyEvents::ReportingEligibilityUpdated.where(policy_id: first_policy.id).first.status).to eq('processing')
    expect(PolicyEvents::ReportingEligibilityUpdated.where(policy_id: second_policy.id).first.status).to eq('processed')
  end
end