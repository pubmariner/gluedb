require "rails_helper"

describe EnrollmentAction::TerminatePolicyWithEarlierDate, "given an EnrollmentAction array that:
  - has one element that has earlier termination date
  - has one element that has future termination date
  - has more than one element" do

  let(:event_1) { instance_double(ExternalEvents::EnrollmentEventNotification, is_termination?: true, is_reterm_with_earlier_date?: true) }
  let(:event_2) { instance_double(ExternalEvents::EnrollmentEventNotification, is_termination?: true, is_reterm_with_earlier_date?: false) }

  subject { EnrollmentAction::TerminatePolicyWithEarlierDate }

  it "qualifies" do
    expect(subject.qualifies?([event_1])).to be_truthy
  end

  it "does not qualify" do
    expect(subject.qualifies?([event_2])).to be_false
  end

  it "does not qualify" do
    expect(subject.qualifies?([event_1, event_2])).to be_false
  end
end

describe EnrollmentAction::TerminatePolicyWithEarlierDate, "given a valid enrollment" do
  let(:member) { instance_double(Openhbx::Cv2::EnrolleeMember, id: 1) }
  let(:enrollee) { instance_double(::Openhbx::Cv2::Enrollee, member: member) }
  let(:terminated_policy_cv) { instance_double(Openhbx::Cv2::Policy, enrollees: [enrollee])}
  let(:policy) { instance_double(Policy, hbx_enrollment_ids: [1]) }

  context "when policy found" do

    let(:termination_event) { instance_double(
        ::ExternalEvents::EnrollmentEventNotification,
        policy_cv: terminated_policy_cv,
        existing_policy: policy,
        all_member_ids: [1,2]
    ) }

    before do
      allow(termination_event.existing_policy).to receive(:terminate_as_of).and_return(true)
      allow(termination_event).to receive(:subscriber_end).and_return(false)
    end

    subject do
      EnrollmentAction::TerminatePolicyWithEarlierDate.new(termination_event, nil)
    end

    it "persists" do
      expect(subject.persist).to be_truthy
    end
  end

  context "when policy not found" do

    let!(:new_termination_event) { instance_double(
        ::ExternalEvents::EnrollmentEventNotification,
        policy_cv: terminated_policy_cv,
        existing_policy: nil,
        all_member_ids: [1,2]
    ) }

    subject do
      EnrollmentAction::TerminatePolicyWithEarlierDate.new(new_termination_event, nil)
    end

    it "return false" do
      expect(subject.persist).to be_false
    end

  end
end

describe EnrollmentAction::TerminatePolicyWithEarlierDate, "given a valid enrollment" do
  let(:amqp_connection) { double }
  let(:termination_event_xml) { double }
  let(:event_xml) { double }

  let(:reinstate_action_helper) { double }
  let(:carrier) { instance_double(Carrier, requires_reinstate_for_earlier_termination: true) }
  let(:event_responder) { instance_double(::ExternalEvents::EventResponder, connection: amqp_connection) }
  let(:enrollee) { double(m_id: 1, coverage_start: :one_month_ago) }
  let(:policy) { instance_double(Policy, id: 1, enrollees: [enrollee], eg_id: 1, carrier: carrier) }

  let(:termination_event) { instance_double(
      ::ExternalEvents::EnrollmentEventNotification,
      event_xml: termination_event_xml,
      existing_policy: policy,
      all_member_ids: [enrollee.m_id],
      event_responder: event_responder,
      hbx_enrollment_id: 1,
      employer_hbx_id: 1
  ) }

  let(:action_helper_result_xml) { double }

  let(:action_helper) { instance_double(
      EnrollmentAction::ActionPublishHelper,
      to_xml: action_helper_result_xml
  ) }

  subject do
    the_action = EnrollmentAction::TerminatePolicyWithEarlierDate.new(termination_event, nil)
    the_action.existing_policy = policy
    the_action
  end

  before :each do
    allow(EnrollmentAction::ActionPublishHelper).to receive(:new).with(termination_event_xml).and_return(action_helper)
    allow(action_helper).to receive(:set_policy_id).with(policy.id)
    allow(action_helper).to receive(:set_member_starts).with({1 => enrollee.coverage_start})
    allow(action_helper).to receive(:keep_member_ends).with([])
    allow(action_helper).to receive(:set_event_action).with("urn:openhbx:terms:v1:enrollment#reinstate_enrollment")
    allow(action_helper).to receive(:set_event_action).with("urn:openhbx:terms:v1:enrollment#terminate_enrollment")
    allow(subject).to receive(:publish_edi).with(amqp_connection, action_helper_result_xml, termination_event.existing_policy.eg_id, termination_event.employer_hbx_id).and_return([true, {}])
  end

  it "publishes an event of enrollment reinstatment & termiantion" do
    expect(action_helper).to receive(:set_event_action).with("urn:openhbx:terms:v1:enrollment#reinstate_enrollment")
    expect(action_helper).to receive(:set_event_action).with("urn:openhbx:terms:v1:enrollment#terminate_enrollment")
    subject.publish
  end

  it "sets policy id" do
    expect(action_helper).to receive(:set_policy_id).with(1).and_return(true)
    subject.publish
  end

  it "sets member start dates" do
    expect(action_helper).to receive(:set_member_starts).with({ 1 => :one_month_ago })
    subject.publish
  end

  it "clears all member end dates before publishing" do
    expect(action_helper).to receive(:keep_member_ends).with([])
    subject.publish
  end

  it "publishes termination & reinstatment resulting xml to edi" do
    expect(subject).to receive(:publish_edi).exactly(2).times
    subject.publish
  end
end
