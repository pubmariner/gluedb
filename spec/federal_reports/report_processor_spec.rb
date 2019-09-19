require 'rails_helper'

describe ::FederalReports::ReportProcessor, :dbclean => :around_each do
  let(:plan) { FactoryGirl.create(:plan, carrier: carrier, year: 2018, coverage_type: "health", hios_plan_id: "1212") }
  let(:plan) { FactoryGirl.create(:plan, carrier: carrier, year: 2018, coverage_type: "health", hios_plan_id: "1212") }
  let(:carrier) { FactoryGirl.create(:carrier, abbrev: "GhmSi") }
  ["submitted", 'terminated', 'canceled', 'effectuated'].each do |status|
    let(:"#{status}_policy") {FactoryGirl.create(:policy, aasm_state: status, plan: plan, term_for_np: false ) }
  end
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
  let(:void_params) {{:policy_id=> canceled_policy.id, :type=>"void", :void_cancelled_policy_ids => [canceled_policy.id], :void_active_policy_ids => [], :npt=> false}}
  let(:termed_corrected_params) {{:policy_id=> terminated_policy.id, :type=>"corrected", :void_cancelled_policy_ids => [], :void_active_policy_ids => [terminated_policy.id], :npt=> false}}
  let(:termed_original_params) {{:policy_id=> terminated_policy.id, :type=>"original", :void_cancelled_policy_ids =>[], :void_active_policy_ids => [terminated_policy.id], :npt=>false}}
  let(:submitted_corrected_params) {{:policy_id=> submitted_policy.id, :type=>"corrected", :void_cancelled_policy_ids => [canceled_policy.id], :void_active_policy_ids => [submitted_policy.id], :npt=> false}}
  let(:submitted_original_params) {{:policy_id=> submitted_policy.id, :type=>"original", :void_cancelled_policy_ids =>[], :void_active_policy_ids => [submitted_policy.id], :npt=>false}}
  let(:uploader){ ::FederalReports::ReportUploader.new }
  subject { ::FederalReports::ReportProcessor }

  before(:each) do
    submitted_policy
    terminated_policy
    canceled_policy
    effectuated_policy
    allow(::FederalReports::ReportUploader).to receive(:new).and_return(uploader)
    allow(uploader).to receive(:upload).and_return(true)
    Policy.all.each do  |policy| 
      person = FactoryGirl.create(:person, authority_member_id: policy.subscriber.m_id)
      policy.subscriber.update_attributes(m_id: person.authority_member_id)
    end
  end
  
  context "processing cancelled policies" do
    it 'calling the upload_canceled_reports_for() if the policy is cancelled but takes no action with no federal transmission' do
      canceled_policy.subscriber.update_attributes(m_id: canceled_policy.subscriber.m_id )
      canceled_policy.reload
      subject.upload_canceled_reports_for(canceled_policy)
      expect(uploader).to_not have_received(:upload).with(void_params)
    end

    it 'calling the upload_canceled_reports_for() if the policy is cancelled ' do
      canceled_policy.federal_transmissions.create!(batch_id: "2017-02-08T14:00:00Z", content_file: "00001",record_sequence_number:"104618")
      canceled_policy.subscriber.update_attributes(coverage_start: Time.mktime(2018,3,16))
      canceled_policy.reload
      subject.upload_canceled_reports_for(canceled_policy)
      expect(uploader).to have_received(:upload).with(void_params)
    end
  end
    
  context "processing terminated policies" do
    it 'calling the upload_active_reports_for() returns original params if the policy has no fed tranmissions' do
      allow(uploader).to receive(:upload).with(termed_original_params).and_return(true)
      terminated_policy.subscriber.update_attributes(coverage_start: Time.mktime(2018,3,16))
      canceled_policy.subscriber.update_attributes(coverage_start: Time.mktime(2018,3,16))
      canceled_policy.subscriber.update_attributes(m_id: terminated_policy.subscriber.m_id )
      terminated_policy.reload
      subject.upload_active_reports_for(terminated_policy)
      expect(uploader).to have_received(:upload).with(termed_original_params)
    end

    it 'calling the upload_active_reports_for() returns original params if the policy has no fed tranmissions' do
      allow(uploader).to receive(:upload).with(termed_corrected_params).and_return(true)
      terminated_policy.subscriber.update_attributes(coverage_start: Time.mktime(2018,3,16))
      canceled_policy.subscriber.update_attributes(coverage_start: Time.mktime(2018,3,16))
      canceled_policy.subscriber.update_attributes(m_id: terminated_policy.subscriber.m_id )
      terminated_policy.federal_transmissions.create!(batch_id: "2017-02-08T14:00:00Z", content_file: "00001",record_sequence_number:"104618")
      terminated_policy.reload

      subject.upload_active_reports_for(terminated_policy)
      expect(uploader).to have_received(:upload).with(termed_corrected_params)
    end
  end

  context "processing submitted policies" do
    it 'calling the upload_active_reports_for() returns original params if the policy has fed tranmissions' do
      allow(uploader).to receive(:upload).with(submitted_original_params).and_return(true)
      submitted_policy.subscriber.update_attributes(coverage_start: Time.mktime(2018,3,16))
      canceled_policy.subscriber.update_attributes(coverage_start: Time.mktime(2018,3,16))
      canceled_policy.subscriber.update_attributes(m_id: submitted_policy.subscriber.m_id )
      submitted_policy.reload
      subject.upload_active_reports_for(submitted_policy)
      expect(uploader).to have_received(:upload).with(submitted_original_params)
    end

    it 'calling the upload_active_reports_for() returns original params if the policy has no fed tranmissions' do
      submitted_policy.reload
      canceled_policy.reload
      allow(uploader).to receive(:upload).with(submitted_corrected_params).and_return(true)
      submitted_policy.subscriber.update_attributes(coverage_start: Time.mktime(2018,3,16))
      canceled_policy.subscriber.update_attributes(coverage_start: Time.mktime(2018,3,16))
      canceled_policy.subscriber.update_attributes(m_id: submitted_policy.subscriber.m_id )
      submitted_policy.federal_transmissions.create!(batch_id: "2017-02-08T14:00:00Z", content_file: "00001",record_sequence_number:"104618")
      submitted_policy.reload
      subject.upload_active_reports_for(submitted_policy)
      expect(uploader).to have_received(:upload).with(submitted_corrected_params)
    end
  end
end