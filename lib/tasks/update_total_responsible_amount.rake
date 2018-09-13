require File.join(Rails.root,"app","data_migrations","update_total_responsible_amount.rb")

# This rake task updates the kind field for the given policy to "coverall".

# RAILS_ENV=production bundle exec rake migrations:update_total_responsible_amount eg_id="102933" total_responsible_amount="578.32" premium_amount_total="1285.16" employer_contribution="706.84" applied_aptc="applied_aptc" 

namespace :migrations do
  desc "Update Total Responsible Amount"
  UpdateTotalResponsibleAmount.define_task :update_total_responsible_amount => :environment
end
