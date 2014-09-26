require 'rails_helper'

describe Eligibility do

	it "fails validation without required attributes" do
		expect(Eligibility.new).to have(1).errors_on(:determination_date)
	end

	it "fails validation with csr_percent value is out of range" do
		expect(Eligibility.new(csr_percent: 73.0).errors_on(:csr_percent)).to include("value must be between 0 and 1")
		expect(Eligibility.new(csr_percent: -1.0).errors_on(:csr_percent)).to include("value must be between 0 and 1")
	end

	it "passes validation with correct attributes" do
		expect(Eligibility.new(determination_date: Date.today, max_aptc: 250.35, csr_percent: 0.73)).to have(:no).errors_on(:base)
	end

end
