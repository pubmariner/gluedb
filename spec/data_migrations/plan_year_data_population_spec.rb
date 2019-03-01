require "rails_helper"
require 'pry'

describe 'PlanYearDataPopulationScript', :dbclean => :after_each do

  describe '.export_csv' do
    let(:employer) { FactoryGirl.create(:employer_with_plan_year) }
    let(:valid_row_data) {[employer_hbx_id: employer.hbx_id,
      employer_fein: employer.fein,
      effective_period_start_on: employer.plan_year_start,
      effective_period_end_on: employer.plan_year_end,
      carrier_hbx_id: "",
      carrier_fein: ""]}
    it 'finds and assign employer for view' do
      x= PlanYearDataPopulationScript.new("#{Rails.root}/file_path.csv").generate_row(valid_row_data)
      x.status == "matched"

    end
  end
end