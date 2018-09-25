require File.join(Rails.root,"app","data_migrations","update_total_responsible_amount.rb")

# This rake task updates premium amounts on a policy.

# RAILS_ENV=production bundle exec rake migrations:update_total_responsible_amount eg_id="eg_id" policy_id="policy_id" total_responsible_amount="total_responsible_amount" premium_amount_total="premium_amount_total" applied_aptc="applied_aptc"

namespace :migrations do
  desc "Update Total Responsible Amount"
  UpdateTotalResponsibleAmount.define_task :update_total_responsible_amount => :environment
end
