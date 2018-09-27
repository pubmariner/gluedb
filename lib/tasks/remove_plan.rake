require File.join(Rails.root,"app","data_migrations","remove_plan")

# This rake tasks removes plans from the DB
# RAILS_ENV=production bundle exec rake migrations:remove_plan hios_plan_id='12345623-01'

namespace :migrations do 
  desc "Remove Plan"
  RemovePlan.define_task :remove_plan => :environment
end