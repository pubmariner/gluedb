require 'spec_helper'

describe ApplicationGroup do

  describe "instantiates object." do
    it "sets and gets all basic model fields" do
      p0 = Person.create!(name_first: "Dan", name_last: "Aurbach")
      p1 = Person.create!(name_first: "Patrick", name_last: "Carney")

      ag = ApplicationGroup.new(
          e_case_id: "6754632abc",
          is_active: true,
          renewal_consent_through_year: 2017,
          submitted_date: Date.today,
          updated_by: "rspec"
        )
      ag.primary_applicant = p0
      ag.consent_applicant = p0
      ag.applicants = [p0, p1]

      expect(ag.e_case_id).to eql("6754632abc")
      expect(ag.is_active).to eql(true)
      expect(ag.consent_renewal_year).to eql(2017)
      expect(ag.submitted_date).to eql(Date.today)
      expect(ag.updated_by).to eql("rspec")

      expect(ag.applicants.size).to eql(2)
      expect(ag.primary_applicant.name_first).to eql("Dan")
      expect(ag.primary_applicant.name_last).to eql("Aurbach")
    end
  end

  describe "manages embedded associations" do
    it "sets and gets embedded IrsGroup, TaxHousehold and HbxEnrollment attributes" do
      p0 = Person.create!(name_last: "Baldwin", name_first: "Alec")
      p1 = Person.create!(name_last: "Baldwin", name_first: "Daniel")
      p2 = Person.create!(name_last: "Baldwin", name_first: "Billy")
      p3 = Person.create!(name_last: "Baldwin", name_first: "Stephen")

      ag = ApplicationGroup.new(
            e_case_id: "6754632abc", 
            consent_renewal_year: 2017, 
            submitted_date: Date.today
          )
      ag.applicants = [p0, p1, p2, p4]
      ag.primary_applicant = p0
      ag.consent_applicant = p0

      ag.irs_groups = [IrsGroup.new()]
      ag.save!

      ag.tax_households << TaxHousehold.new(
          irs_group_id: ag.irs_groups[0]._id, 
          primary_applicant_id: p0._id
        )

      ag.hbx_enrollments = [HbxEnrollment.new(
          irs_group_id: ag.irs_groups[0]._id, 
          kind: "unassisted_qhp"
        )]

    end

    it "sets and gets email attributes" do
      psn = Person.new
      psn.emails << Email.new(
        email_type: "work",
        email_address: "john.Jingle-Himer@example.com"
      )
    end

end
