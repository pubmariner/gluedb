require File.join(Rails.root,"app","data_migrations","update_aptc_credits.rb")

# This rake task merges people in Glue.
# format RAILS_ENV=production bundle exec rake migrations:update_aptc_credits eg_id="123" tot_res_amt="23.5" 

namespace :migrations do 
  desc "Update Aptc Credits"
  UpdateAptcCredits.define_task :update_aptc_credits => :environment
end