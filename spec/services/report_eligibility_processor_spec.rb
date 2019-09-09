require 'rails_helper'
require File.join(Rails.root, "script", "migrations", "person_family_creator")

describe ReportEligiblityProcessor do
  let(:plan) { instance_double(Plan, carrier: carrier, year: 2018, coverage_type: "health", hios_plan_id: "1212") }
  let(:carrier) { instance_double(Carrier, abbrev: "GhmSi") }

  ["submitted", 'terminated', 'canceled'].each do |status|
    let!(:"#{status}_policy") {double(Policy, aasm_state: status, 
    responsible_party_id:"",
    id: Moped::BSON::ObjectId.new,
    eg_id: Moped::BSON::ObjectId.new,
    enrollees: [enrollee],
    plan: plan,
    spouse:"",
    market: "individual",
    term_for_np:false
    )}
  end

  let!(:records) {[ double(PolicyEvents::ReportingEligibilityUpdated,policy_id: submitted_policy.id),
                    double(PolicyEvents::ReportingEligibilityUpdated,policy_id: terminated_policy.id),
                    double(PolicyEvents::ReportingEligibilityUpdated,policy_id: canceled_policy.id)
                  ]}

  let(:policies){[submitted_policy,terminated_policy,canceled_policy]}
  let(:person) {double(Person, authority_member_id:"456")}
  let(:member) {double(Member, person: person, id:"1233", hbx_member_id:"456")}
  let(:enrollee) {double(Enrollee, m_id: member.hbx_member_id, rel_code: "self", coverage_start: Date.today.prev_year, coverage_end: (Date.today - 1.day))}
  let(:federal_transmission) {double(FederalTransmission)}
  let(:federal_transmissions) {[federal_transmission]}
  let(:policy_report_eligibility_updateds) {[PolicyReportEligibilityUpdated]}
  let(:policy_report_eligibility_updated_policy_ids) {[submitted_policy.id,terminated_policy.id,canceled_policy.id]}
  let(:federal_transmission){ double(FederalTransmission, policy: canceled_policy)}
  let(:federal_transmissions){[federal_transmission]}
  let(:void_params) {{:policy_id=> canceled_policy.id, :type=>"void", :void_cancelled_policy_ids=> [canceled_policy.id], :void_active_policy_ids=>[submitted_policy.id, terminated_policy.id], :npt=> false}}
  let(:corrected_params) {{:policy_id=> submitted_policy.id, :type=>"corrected", :void_cancelled_policy_ids=> [canceled_policy.id], :void_active_policy_ids=>[submitted_policy.id, terminated_policy.id], :npt=> false}}
  let(:original_params) {{:policy_id=> terminated_policy.id, :type=>"original", :void_cancelled_policy_ids=>[canceled_policy.id], :void_active_policy_ids=>[submitted_policy.id, terminated_policy.id], :npt=>false}}
# 
  subject { ReportEligiblityProcessor }

  before(:each) do
    allow(policies) {[]}
    allow(PolicyEvents::ReportingEligibilityUpdated).to receive(:events_for_processing).and_return(records)
    allow(Policy).to receive(:find).with(submitted_policy.id).and_return(submitted_policy)
    allow(Policy).to receive(:find).with(terminated_policy.id).and_return(terminated_policy)
    allow(Policy).to receive(:find).with(canceled_policy.id).and_return(canceled_policy)
    allow(canceled_policy).to receive(:federal_transmissions).and_return(federal_transmissions)
    allow(canceled_policy).to receive(:subscriber).and_return(enrollee)
    allow(terminated_policy).to receive(:subscriber).and_return(enrollee)
    allow(terminated_policy).to receive(:federal_transmissions).and_return(nil)
    allow(submitted_policy).to receive(:federal_transmissions).and_return(federal_transmissions)
    allow(submitted_policy).to receive(:subscriber).and_return(enrollee)
    allow(canceled_policy).to receive(:canceled?).and_return(true)
    allow(enrollee).to receive(:canceled?).and_return(false)
    allow(enrollee).to receive(:policies).and_return(policies)
    allow(enrollee).to receive(:person).and_return(person)
    allow(person).to receive(:authority_member).and_return(member)
    allow_any_instance_of(Generators::Reports::IrsYearlySerializer).to receive(:generate_notice).and_return("file_name")
    allow(subject).to receive(:upload_to_s3).and_return(true)
    allow(subject).to receive(:publish_to_sftp).and_return(true)
    allow(subject).to receive(:persist_new_doc).and_return(true)
    allow(subject).to receive(:persist_new_doc).and_return(true)
    allow(subject).to receive(:generate_1095A_pdf).with(void_params).and_return(true)
    allow(subject).to receive(:generate_1095A_pdf).with(corrected_params).and_return(true)
    allow(subject).to receive(:generate_1095A_pdf).with(original_params).and_return(true) 
  end
  
  context "creating 1095As" do
    it 'send the the correct params to the 1095A generator' do
      allow(subject).to receive(:transmit)
      allow(subject).to receive(:transmit)
      allow(subject).to receive(:transmit)  
      subject.run
      expect(subject).to have_received(:transmit).with(void_params)
      expect(subject).to have_received(:transmit).with(corrected_params)
      expect(subject).to have_received(:transmit).with(original_params)
    end

    it 'transmits the 1095A' do
      subject.run
      expect(subject).to have_received(:persist_new_doc).exactly(3).times
      expect(subject).to have_received(:upload_to_s3).exactly(3).times
      expect(subject).to have_received(:publish_to_sftp).exactly(3).times
    end

  end
end