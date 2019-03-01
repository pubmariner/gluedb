# require File.join(Rails.root, "script", "migrations", "family_for_policy_creator")
# require File.join(Rails.root, "app", "models", "queries", "policies_with_no_families")
require 'csv'

class PlanYearData
 def intialize(file_path)
   csv_path = File.read(file_path)	
   @csv = CSV.parse(csv_path, :headers => true) 
 end

  def pull_plan_year(start_date, fein)
   plan_years = Employer.where(fein: fein).first.plan_years.where(:"start_date" => {"$eq" => start_date})
   return employer
  end

  def fetch_plan_year_by_year(start_date, fein)
   plan_years = Employer.where(fein: fein).first.plan_years.select{|py| py.start_date.year >= start_date.year}
   return employer
  end


  def export_csv
   field_names = %w(employer_hbx_id employer_fein plan_year_start plan_year_end matched results)
   timestamp = Time.now.strftime('%Y%m%d%H%M')
   export_csv_path = File.expand_path("#{Rails.root}/plan_year_data_population_#{timestamp}.csv")
   export_csv_path << field_names
   @csv.each do |row|
   	employer_hbx_id = row.employer_hbx_id
   	employer_fein = row.employer_fein
   	plan_year_start = row.plan_year_start
   	plan_year_end = row.plan_year_end
    plan_years = pull_plan_year(plan_year_start, employer_fein)
    status = ""

    case plan_years.count
    when 1
    	 if (plan_years.first.start_date == plan_year_start) && (plan_years.first.end_date == plan_year_end)
    	 	status = "macthed"
    	 	results = "not updated"
    	 else
    	 	plan_years.first.update_attributes(start_date: plan_year_start, end_date: plan_year_end)
    	 	status = "matched"
    	 	results = "updated end date"
         end
    when 0
    	status = "unmatched"
    	year_based_plan_years = fetch_plan_year_by_year(plan_year_start, employer_fein)
    	 if year_based_plan_years.count > 1 || year_based_plan_years.count == 0
    	 	results = "found too many plan years with given start_date or bad data"
    	 else 
    	 	year_based_plan_years.first.update_attributes(start_date: plan_year_start, end_date: plan_year_end)
    	 	results = "udpated both start_date and end date"
    	 end
   else
   	  status = "un matched"
   	  results = "Did not found matching plan year with start date"
   end 	 

   	csv << [employer_hbx_id, employer_fein, plan_year_start, plan_year_end status results]

   end
 end

 class_instance = PlanYearData.new("#{Rails.root}/file_name.csv")
 class_instance.export_csv


  end

end
