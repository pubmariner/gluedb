require 'rails_helper'

describe ::FederalReports::ReportEligiblityDetermination, :dbclean => :after_each do
  let(:plan) { FactoryGirl.create(:plan, carrier: carrier, year: 2018, coverage_type: "health", hios_plan_id: "1212") }
  let(:plan) { FactoryGirl.create(:plan, carrier: carrier, year: 2018, coverage_type: "health", hios_plan_id: "1212") }
  let(:carrier) { FactoryGirl.create(:carrier, abbrev: "GhmSi") }
  ["submitted", 'terminated', 'canceled', 'effectuated'].each do |status|
    let!(:"#{status}_policy") {FactoryGirl.create(:policy, aasm_state: status, plan: plan, term_for_np: false ) }
  end
  let(:bad_policy) {FactoryGirl.create(:policy, aasm_state: "effectuated")}
  let!(:records) {[ double(policy_id: submitted_policy.id),
                    double(policy_id: terminated_policy.id),
                    double(policy_id: canceled_policy.id)
                  ]}
  let(:policies){[submitted_policy, terminated_policy, canceled_policy]}
  let(:federal_transmission) {double(FederalTransmission)}
  let(:federal_transmissions) {[federal_transmission]}
  let(:policy_report_eligibility_updateds) {[PolicyReportEligibilityUpdated]}
  let(:policy_report_eligibility_updated_policy_ids) {[submitted_policy.id, terminated_policy.id, canceled_policy.id]}
  let(:federal_transmission){ double(FederalTransmission, policy: canceled_policy)}
  let(:federal_transmissions){[federal_transmission]}
  let(:void_params) {{:policy_id=> canceled_policy.id, :type=>"void", :void_cancelled_policy_ids => [canceled_policy.id], :void_active_policy_ids => [submitted_policy.id, terminated_policy.id], :npt=> false}}
  let(:corrected_params) {{:policy_id=> submitted_policy.id, :type=>"corrected", :void_cancelled_policy_ids => [canceled_policy.id], :void_active_policy_ids => [submitted_policy.id, terminated_policy.id], :npt=> false}}
  let(:original_params) {{:policy_id=> terminated_policy.id, :type=>"original", :void_cancelled_policy_ids =>[canceled_policy.id], :void_active_policy_ids => [submitted_policy.id, terminated_policy.id], :npt=>false}}
  
  subject { ::FederalReports::ReportEligiblityDetermination }

  before(:each) do
    Policy.all.each{ |policy| FactoryGirl.create(:person, authority_member_id: policy.subscriber.m_id)}
    allow(::PolicyEvents::ReportingEligibilityUpdated).to receive(:events_for_processing).and_return(records)
    allow(::FederalReports::ReportProcessor).to receive(:transmit_cancelled_reports_for).with(canceled_policy).and_return(true)
    allow(::FederalReports::ReportProcessor).to receive(:transmit_active_reports_for).with(submitted_policy).and_return(true)
    allow(::FederalReports::ReportProcessor).to receive(:transmit_active_reports_for).with(terminated_policy).and_return(true)
  end
  
  context "processing cancelled policies" do
    it 'calls the transmit_cancelled_reports_for() if the policy is cancelled' do
      subject.determine_report_transmission_type
    
      expect(::FederalReports::ReportProcessor).to have_received(:transmit_cancelled_reports_for).with(canceled_policy)
      expect(::FederalReports::ReportProcessor).to_not have_received(:transmit_cancelled_reports_for).with(terminated_policy)
      expect(::FederalReports::ReportProcessor).to_not have_received(:transmit_cancelled_reports_for).with(submitted_policy)
    end
  end

  context "processing terminated policies" do
    it 'calls the transmit_active_reports_for() if the policy is terminated' do
      subject.determine_report_transmission_type
      expect(::FederalReports::ReportProcessor).to have_received(:transmit_active_reports_for).with(terminated_policy)
      expect(::FederalReports::ReportProcessor).to_not have_received(:transmit_active_reports_for).with(canceled_policy)
    end
  end

  context "processing submitted policies" do
    it 'calls the transmit_active_reports_for() if the policy is submitted' do
      subject.determine_report_transmission_type
      expect(::FederalReports::ReportProcessor).to have_received(:transmit_active_reports_for).with(submitted_policy)
    end
  end

  context "not processing unqualified policies" do
    it 'does not call the ReportProcessor class if the policy does not quality' do
      subject.determine_report_transmission_type
      expect(::FederalReports::ReportProcessor).to_not have_received(:transmit_active_reports_for).with(effectuated_policy)
    end
  end
end