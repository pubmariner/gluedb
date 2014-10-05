require 'rails_helper'
require 'active_support/time'

describe AssistanceEligibility do

  before(:all) do

    @assistance_eligibility = AssistanceEligibility.new

    alternate_benefit = AlternateBenefit.new
    alternate_benefit.start_date = Date.new(2011, 01, 01)
    alternate_benefit.end_date = Date.new(2015, 03, 03)

    alternate_benefit2 = AlternateBenefit.new
    alternate_benefit2.start_date = Date.new(2013, 01, 01)
    alternate_benefit2.end_date =  Date.new(2013, 03, 03)


    deduction1 = Deduction.new
    deduction1.amount_in_cents = 470
    deduction1.start_date = Date.new(2013, 01, 01)
    deduction1.end_date = nil
    deduction1.frequency = "yearly"


    income1 = Income.new
    income1.amount_in_cents = 111400
    income1.start_date = Date.new(2012, 04, 12)
    income1.end_date = nil
    income1.frequency = "monthly"

    income2 = Income.new
    income2.amount_in_cents = 120030
    income2.start_date = Date.new(2013, 10, 02)
    income2.end_date = nil
    income2.frequency = "monthly"

    income3 = Income.new
    income3.amount_in_cents = 111400
    income3.start_date = nil
    income3.end_date = nil
    income3.frequency = "monthly"

    income4 = Income.new
    income4.amount_in_cents = 120030
    income4.start_date = nil
    income4.end_date = nil
    income4.frequency = "monthly"


    @assistance_eligibility.incomes << income1 << income2 << income3 << income4

    @assistance_eligibility.deductions << deduction1

    @assistance_eligibility.alternate_benefits << alternate_benefit << alternate_benefit2


end

  context "yearwise income computation" do

    it "should compute the income hash" do


      income_hash = @assistance_eligibility.compute_yearwise(@assistance_eligibility.incomes)

      expect(((income_hash[2014]) - 5553600).abs).to be < 1000
    end
  end

  context "yearwise deductions computation" do

    it "should compute the deductions hash" do


      deduction_hash = @assistance_eligibility.compute_yearwise(@assistance_eligibility.deductions)

      expect(((deduction_hash[2014]) - 470).abs).to be < 1000
    end
  end

  it "should check for benifits in current year" do


    expect(@assistance_eligibility.is_receiving_benefit?).to be_true
  end

end