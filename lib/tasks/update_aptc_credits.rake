require File.join(Rails.root,"app","data_migrations","update_aptc_credits.rb")

# format RAILS_ENV=production bundle exec rake migrations:update_aptc_credits eg_id="abc123" total_responsible_amount="total_responsible_amount" premium_amount_total="premium_amount_total" 

namespace :migrations do
  desc "Update APTC credits"
  UpdateAptcCredits.define_task :update_aptc_credits => :environment
end