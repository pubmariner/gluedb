require 'rails_helper'

describe AlternateBenefit do
  describe "validate associations" do
    it { should be_embedded_in :assistance_eligibility }
  end

 let(:attributes) do
    {
      kind: :medicaid,
      income_type: 'wages_and_salaries',
      frequency: 'biweekly',
      start_date: Time.new(1980,10,23,0,0,0),
      end_date: Time.new(1980,10,23,0,0,0),
      submission_date: Date.today
    }
  end

end