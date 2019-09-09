require 'rails_helper'
require File.join(Rails.root, "script", "migrations", "person_family_creator")

describe ReportEligiblityProcessor do
  let(:plan) { instance_double(Plan, carrier: carrier, year: 2018, coverage_type: "health", hios_plan_id: "1212") }
  let(:carrier) { instance_double(Carrier, abbrev: "GhmSi") }

  ["submitted", 'terminated', 'canceled'].each_with_index do |status , i|
    let!(:"#{status}_policy") {double(Policy, aasm_state: status, 
    responsible_party_id:"",
    id: (i + 1).to_s,
    eg_id: (i + 1).to_s,
    enrollees: [enrollee],
    plan: plan,
    spouse:"",
    market: "individual",
    term_for_np:false
    )}
  end

  let!(:policies) {[submitted_policy, terminated_policy, canceled_policy]}
  let(:person) {double(Person, authority_member_id:"456")}
  let(:member) {double(Member, person: person, id:"1233", hbx_member_id:"456")}
  let(:enrollee) {double(Enrollee, m_id: member.hbx_member_id, rel_code: "self", coverage_start: Date.today.prev_year, coverage_end: (Date.today - 1.day))}
  let(:federal_transmission) {double(FederalTransmission)}
  let(:federal_transmissions) {[federal_transmission]}
  let(:policy_report_eligibility_updateds) {[PolicyReportEligibilityUpdated]}
  let(:policy_report_eligibility_updated_policy_ids) {["1",'2','3']}
  let(:federal_transmission){ double(FederalTransmission, policy: canceled_policy)}
  let(:federal_transmissions){[federal_transmission]}
  let(:void_params) {{:policy_id=>"3", :type=>"void", :void_cancelled_policy_ids=>["3"], :void_active_policy_ids=>["1", "2"], :npt=>false}}
  let(:corrected_params) {{:policy_id=>"1", :type=>"corrected", :void_cancelled_policy_ids=>["3"], :void_active_policy_ids=>["1", "2"], :npt=>false}}
  let(:original_params) {{:policy_id=>"2", :type=>"original", :void_cancelled_policy_ids=>["3"], :void_active_policy_ids=>["1", "2"], :npt=>false}}
# 
  subject { ReportEligiblityProcessor }

  before(:each) do
    allow(PolicyEvents::ReportingEligibilityUpdated).to receive(:events_for_processing).and_return(policies)
    allow(Policy).to receive(:find).with("1").and_return(submitted_policy)
    allow(Policy).to receive(:find).with("2").and_return(terminated_policy)
    allow(Policy).to receive(:find).with("3").and_return(canceled_policy)
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
    allow(subject).to receive(:persist_new_doc)
    
  end
  
  context "creating 1095s" do
    it 'send the the correct params to the 1095 generator' do
      allow(subject).to receive(:generate_1095A_pdf).with(void_params)
      allow(subject).to receive(:generate_1095A_pdf).with(corrected_params)
      allow(subject).to receive(:generate_1095A_pdf).with(original_params)
      
      subject.run
      
      expect(subject).to have_received(:generate_1095A_pdf).with(void_params)
      expect(subject).to have_received(:generate_1095A_pdf).with(corrected_params)
      expect(subject).to have_received(:generate_1095A_pdf).with(original_params)
    end

    it 'persists the created doc' do
      subject.run
      expect(subject).to have_received(:persist_new_doc).exactly(3).times
    end
  end
end