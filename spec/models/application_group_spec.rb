require 'rails_helper'

describe ApplicationGroup do

  let(:p0) {Person.create!(name_first: "Dan", name_last: "Aurbach")}
  let(:p1) {Person.create!(name_first: "Patrick", name_last: "Carney")}
  let(:a0) {ApplicantLink.new(person: p0)}
  let(:a1) {ApplicantLink.new(person: p1)}


  describe "instantiates object." do
    it "sets and gets all basic model fields" do
      ag = ApplicationGroup.new(
          e_case_id: "6754632abc",
          is_active: true,
          renewal_consent_through_year: 2017,
          submitted_date: Date.today,
          updated_by: "rspec"
        )

      ag.applicants = [p0, p1]
      ag.primary_applicant = p0
      ag.consent_applicant = p0

      expect(ag.e_case_id).to eql("6754632abc")
      expect(ag.is_active).to eql(true)
      expect(ag.renewal_consent_through_year).to eql(2017)
      expect(ag.submitted_date).to eql(Date.today)
      expect(ag.updated_by).to eql("rspec")

      expect(ag.applicants.size).to eql(2)
      expect(ag.primary_applicant.name_first).to eql("Dan")
      expect(ag.consent_applicant.name_last).to eql("Aurbach")
    end
  end

  describe "manages embedded associations." do

    let(:ag) {
      ApplicationGroup.create!(
          e_case_id: "6754632abc", 
          renewal_consent_through_year: 2017, 
          submitted_date: Date.today,
          applicants: [p0, p1],
          primary_applicant: p0,
          consent_applicant: p0,
          irs_groups: [IrsGroup.new()]
        )  
    }

    let(:th) {
      TaxHousehold.new(
        primary_applicant: p0,
        irs_group: ag.irs_groups.first,
        applicant_links: [a0, a1]
      )
    }

    let(:he) {
      HbxEnrollment.new(
        primary_applicant: p1,
        irs_group: ag.irs_groups.first,
        kind: "unassisted_qhp",
        allocated_aptc_in_dollars: 125.00,
        csr_percent_as_integer: 71,
        applicant_links: [a1]
      )
    }

    it "sets and gets embedded IrsGroup, TaxHousehold and HbxEnrollment associations and attributes" do

      ag.tax_households  = [th]
      ag.hbx_enrollments = [he]

      expect(ag.tax_households.first.primary_applicant_id).to eql(p0._id)
      expect(ag.tax_households.first.applicant_links.first.person._id).to eql(a0.person_id)

      expect(ag.hbx_enrollments.first.primary_applicant_id).to eql(p1._id)
      expect(ag.hbx_enrollments.first.allocated_aptc_in_cents).to eql(12500)
      expect(ag.hbx_enrollments.first.csr_percent_as_integer).to eql(71)
      expect(ag.hbx_enrollments.first.applicant_links.first.person_id).to eql(a1.person_id)

      # Access the hbx_enrollment and tax_household properties via the IrsGroup association
      expect(ag.irs_groups.first.hbx_enrollments.first.kind).to eql("unassisted_qhp")
      expect(ag.irs_groups.first.tax_households.first.primary_applicant_id).to eql(p0._id)
      expect(ag.irs_groups.first.hbx_enrollments.first.primary_applicant_id).to eql(p1._id)
    end

    it "sets and gets HbxEnrollment Policy associations" do

      broker = Broker.create!(
        b_type: "broker",
        name_first: "Tom",
        name_last: "Schultz",
        npn: "345987012",
        addresses: [Address.new(
          address_type: "work", 
          address_1: "1 Copley Plaza", 
          city: "Boston", 
          state: "MA",
          zip: "03814")]
        )

      policy = Policy.create!(
        eg_id: "abc123xyz",
        pre_amt_tot: 750,
        tot_res_amt: 650,
        applied_aptc: 100,
        carrier_to_bill: true
        ) 

      expect(ag.policies.size).to eql(0)
      expect(ag.brokers.size).to eql(0)

      ag.hbx_enrollments = [he]
      he.policy = policy
      he.broker = broker
      ag.save!

      # Verify the ApplicationGroup::HbxEnrollment side of association
      expect(ag.policies.size).to eql(1)
      expect(ag.hbx_enrollments.first.policy_id).to eql(policy._id)
      expect(ag.policies.first.pre_amt_tot).to eql(750)

      # Verify the ApplicationGroup::Brokers side of association
      expect(ag.brokers.size).to eql(1)
      expect(ag.brokers.first._id).to eql(broker._id)

      # Verify the Policy side of association
      expect(policy.hbx_enrollment._id).to eql(ag.hbx_enrollments.first._id)

      # Verify the Broker side of association
      expect(broker.application_groups.first._id).to eql(ag._id)
    end
  end
end
