require "rails_helper"
require 'pry'

require File.join(Rails.root, "script", "migrations", "plan_year_data_population_script")

describe 'PlanYearDataPopulationScript', :dbclean => :after_each do

  after :each do
    File.delete("#{Rails.root}/plan_year_data_test.csv") if File.exist?("#{Rails.root}/plan_year_data_test.csv")
  end

  describe '.export_csv' do

    it 'finds and assign employer for view' do
      employer = FactoryGirl.create(:employer_with_plan_year)
      employer1 = FactoryGirl.create(:employer_with_plan_year)
      # employer2 = FactoryGirl.create(:employer_with_plan_year) 

      file = "#{Rails.root}/public/user_data.csv"

      field_names = %w(employer_hbx_id employer_fein effective_period_start_on effective_period_end_on carrier_hbx_id carrier_fein)
      export_csv_path = File.expand_path("#{Rails.root}/plan_year_data_test.csv")
      CSV.open(export_csv_path, 'w', write_headers: true, headers: field_names) do |csv|
        csv << [employer.hbx_id, employer.fein, employer.plan_years.first.start_date, employer.plan_years.first.end_date, "", ""]
        csv << [employer1.hbx_id, employer1.fein, employer1.plan_years.first.start_date, employer1.plan_years.first.end_date + 1.month, "", ""]
      end

      x = PlanYearDataPopulationScript.new("#{Rails.root}/plan_year_data_test.csv").export_csv
    end
  end

  describe "Unmatched Plan Year" do

    it 'finds and assign employer for view' do
      employer = FactoryGirl.create(:employer_with_plan_year)
      employer1 = FactoryGirl.create(:employer_with_plan_year)
      # employer2 = FactoryGirl.create(:employer_with_plan_year)

      field_names = %w(employer_hbx_id employer_fein effective_period_start_on effective_period_end_on carrier_hbx_id carrier_fein)
      export_csv_path = File.expand_path("#{Rails.root}/plan_year_data_test.csv")

      CSV.open(export_csv_path, 'w', write_headers: true, headers: field_names) do |csv|
        csv << [employer.hbx_id, employer.fein, employer.plan_years.first.start_date + 1.year, employer.plan_years.first.end_date, "", ""]
        csv << [employer1.hbx_id, employer1.fein, employer1.plan_years.first.start_date + 1.year, employer1.plan_years.first.end_date + 1.month, "", ""]
      end
      x = PlanYearDataPopulationScript.new("#{Rails.root}/plan_year_data_test.csv").export_csv
    end
  end
end
