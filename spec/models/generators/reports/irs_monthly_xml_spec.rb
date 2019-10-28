require 'rails_helper'

module Generators::Reports
  describe IrsMonthlyXml, :dbclean => :after_each do

    let(:slcsp_hios)   { {:slcsp => "94506DC0390014-01"} }
    let!(:plan)        { FactoryGirl.create(:plan) }
    let!(:silver_plan) { FactoryGirl.create(:plan, hios_plan_id: slcsp_hios[:slcsp]) }
    let(:calender_year) { 2018 }
    let(:irs_settings) { 
      settings = YAML.load(File.read("#{Rails.root}/config/irs_settings.yml")).with_indifferent_access 
      settings['tax_document'].merge!({calender_year => slcsp_hios })
      settings
    }
    
    let!(:primary) {
      person = FactoryGirl.create :person, dob: Date.new(1970, 5, 1) 
      person.update(authority_member_id: person.members.first.hbx_member_id)
      person
    }

    let!(:child)   { 
      person = FactoryGirl.create :person, dob: Date.new(1998, 9, 6) 
      person.update(authority_member_id: person.members.first.hbx_member_id)
      person
    }

    let(:primary_family_member) {
      family_member = FamilyMember.new(is_primary_applicant: true, is_consent_applicant: true)
      family_member.person = primary
      family_member
    }

    let(:child_family_member) {
      family_member = FamilyMember.new
      family_member.person = child
      family_member 
    }

    let(:coverage_end) { Date.new(calender_year, 6, 30) }

    let(:policy) {
      policy = FactoryGirl.create :policy, plan_id: plan.id, coverage_start: Date.new(calender_year, 1, 1), coverage_end: coverage_end
      policy.enrollees[0].m_id = primary.authority_member.hbx_member_id
      policy.enrollees[1].m_id = child.authority_member.hbx_member_id
      policy.enrollees[1].rel_code ='child'; policy.save
      policy
    }

    let!(:family) {
      family = FactoryGirl.build(:family)
      family.family_members = [primary_family_member, child_family_member]
      family.irs_groups.build
      household = family.households.new(effective_start_date: Date.today.beginning_of_year)
      household.hbx_enrollments.build(policy_id: policy.id, kind: 'unassisted_qhp'); family.save
      family
    }

    let(:file) { Rails.root.join("#{family.e_case_id}_#{subject.identification_num}.xml") }

    subject { 
      group_builder = Generators::Reports::IrsGroupBuilder.new(family)
      group_builder.calender_year = calender_year
      group_builder.npt_policies  = []
      group_builder.settings = irs_settings
      group_builder.process
      group_builder.irs_group
    }

    it 'should build households and tax households' do
      expect(subject.households).to be_present
      expect(subject.households.first.tax_households).to be_present
      expect(subject.identification_num).to be_present
    end

    it 'should build insurance policies ' do
      expect(subject.insurance_policies).to be_present
      expect(subject.insurance_policies.first.monthly_premiums.count).to eq coverage_end.month
    end

    it 'should generate monthly xml' do 
      group_xml = Generators::Reports::IrsMonthlyXml.new(subject, family.e_case_id)
      group_xml.folder_path = Rails.root.to_s
      group_xml.serialize

      expect(File.exists?(file)).to be_truthy
    end
  end
end