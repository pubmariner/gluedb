require 'rails_helper'

describe SpecialEnrollmentPeriod do
	it "fails validation with no 'reason' attribute" do
		expect(SpecialEnrollmentPeriod.new).to have(2).errors_on(:reason)
		expect(SpecialEnrollmentPeriod.new.errors_on(:reason)).to include("can't be blank")
	end

	it "fails validation with no start_date (using errors_on)" do
		expect(SpecialEnrollmentPeriod.new).to have(1).errors_on(:start_date)
	end

	it "fails validation with no end_date (using errors_on)" do
		expect(SpecialEnrollmentPeriod.new).to have(1).errors_on(:end_date)
	end

	it "fails validation when end_date preceeds start_date" do
		expect(SpecialEnrollmentPeriod.new(start_date: Date.today, end_date: Date.today - 1)).to have(1).errors_on(:end_date)
		expect(SpecialEnrollmentPeriod.new(start_date: Date.today, end_date: Date.today - 1).errors_on(:end_date)).to include("end_date cannot preceed start_date")
	end

	it "fails validation with 'reason' attribute value not in enumerated set" do
		expect(SpecialEnrollmentPeriod.new(reason: "unspecified")).to have(1).errors_on(:reason)
	end

	it "passes validation with a 'reason' attribute value in enumerated set" do
		expect(SpecialEnrollmentPeriod.new(reason: 'birth')).to have(0).errors_on(:reason)
	end

end
