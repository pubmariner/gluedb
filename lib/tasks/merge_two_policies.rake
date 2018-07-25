require File.join(Rails.root,"app","data_migrations","merge_two_policies.rb")

# This rake task merges people in Glue.
# format RAILS_ENV=production bundle exec rake migrations:merge_two_policies policy_to_keep='1' policy_to_remove='2' policy_of_final_tot_res_amt="1" policy_of_final_pre_amt_tot="1" policy_of_final_tot_emp_res_amt='1' policy_of_final_rating_area="1" policy_of_final_composite_rating_tier="1" 
namespace :migrations do 
  desc "Merge Two Policies"
  MergeTwoPolicies.define_task :merge_two_policies => :environment
end