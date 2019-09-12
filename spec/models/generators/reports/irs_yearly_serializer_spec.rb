require 'rails_helper'

module Generators::Reports
  describe IrsYearlySerializer do

    let(:member) {double(Member, hbx_member_id: Moped::BSON::ObjectId.new, ssn: "00000000", dob: (Date.today - 21.years))} 
    let(:address)  { double(Address, state:"CA", address_1:"test", address_2:"test 2", city: 'city', zip: "12022", street_1:"street 1", street_2: "street 2") }
    let(:enrollee) {double(Enrollee, rel_code: "self", coverage_start: (Date.today - 1.year), coverage_end: (Date.today - 1.day), person: person) }
    let(:plan) {double(Plan, hios_plan_id: "23232323", ehb: 12)}  
    let(:params) { {  policy_id: policy.id, type: "original", void_cancelled_policy_ids: [ Moped::BSON::ObjectId.new ] , void_active_policy_ids: [ Moped::BSON::ObjectId.new ], npt: policy.term_for_np } }
    let(:household) {double(name:"name", ssn:"00000000")}
    let(:options) { { multiple: false, calender_year: 2018, qhp_type: "assisted", notice_type: 'new'} }
    let(:premium) {double(premium_amount:100, slcsp_premium_amount: 200, aptc_amount:0)}
    let(:report) { Generators::Reports::IrsYearlyPdfReport.new(notice, options)  }  
    let!(:xml_generator) { IrsYearlySerializer.new(params, true) }
    let(:monthly_premiums) { [OpenStruct.new({serial: (1), premium_amount: 0.0, premium_amount_slcsp: 0.0, monthly_aptc: 0.0})] }  
    let(:person) { double(Person, 
                   authority_member: member,
                   mailing_address: address,
                   ssn: "00000000",
                   full_name: "name",
                   name_last: "last",
                   name_first: "first", 
                   name_sfx: "sfx",
                   name_middle: "middle",
                   name: "name",
                   coverage_start_date: (Date.today - 1.year).strftime("%Y%m%d"),
                   coverage_termination_date: (Date.today).strftime("%Y%m%d")) }  
                            
    let(:policy) { double(Policy,
                   id: Moped::BSON::ObjectId.new,
                   term_for_np: false,
                   responsible_party_id:"",
                   spouse: nil,
                   applied_aptc: 0,
                   pre_amt_tot: 123,
                   multi_aptc?: false,
                   plan: plan,
                   coverage_period: (enrollee.coverage_start..enrollee.coverage_end),
                   carrier_id:  Moped::BSON::ObjectId.new,
                   policy_start: enrollee.coverage_start,
                   policy_end: enrollee.coverage_end) } 


    let(:notice) { double(subscriber_hbx_id: "333332",
                   recipient: person,
                   yearly_premium:premium,
                   spouse:"",
                   name:"name",
                   has_aptc: false,
                   canceled?: false,
                   monthly_premiums: monthly_premiums,
                   recipient_address: person.mailing_address,
                   policy_id: "23232323",
                   issuer_name: "CareFirst",
                   covered_household: [person],
                   enrollees:[enrollee],
                   id: policy.id) }



    before(:each) do
      FileUtils.rm_rf(Dir["#{Rails.root}/irs/"])
      FileUtils.rm_rf(Dir["#{Rails.root}/tmp/irs_notices"])
      allow(Policy).to receive(:find).and_return(policy)
      allow(policy).to receive(:enrollees).and_return([enrollee])
      allow(enrollee).to receive(:canceled?).and_return(false)
      allow(policy).to receive(:canceled?).and_return(false)
      allow(policy).to receive(:belong_to_authority_member?).and_return(true)
      allow(policy).to receive(:subscriber).and_return(enrollee)
      allow(policy).to receive(:subscriber).and_return(enrollee)
      allow(policy).to receive(:changes_over_time?).and_return(false)
      allow(policy).to receive(:ehb_premium).and_return(1)
      allow(Generators::Reports::IrsYearlyPdfReport).to receive(:new).and_return(report)
      allow(subject).to receive(:append_report_row).and_return(true)
      allow(xml_generator).to receive(:merge_and_validate_xmls).and_return(true)

    end

    subject { IrsYearlySerializer.new(params) }
    
    context '#generate_notice' do
      it 'generates a 1095A file' do 
          expect(File).not_to exist("#{Rails.root}/tmp/irs_notices/") 
          subject.generate_notice
          expect(File).to exist("#{Rails.root}/tmp/irs_notices/") 
          FileUtils.rm_rf(Dir["#{Rails.root}/tmp/irs_notices"])
      end
    end 

    context '#process_policy' do
      it 'generates a h41 file' do 
        expect(File).not_to exist("#{Rails.root}/irs/") 
        xml_generator.process_policy(policy)
        expect(File).to exist("#{Rails.root}/irs/") 
        FileUtils.rm_rf(Dir["#{Rails.root}/irs/"])
      end
    end

  end
end