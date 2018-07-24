require File.join(Rails.root,"app","data_migrations","merge_two_policies.rb")

# This rake task merges people in Glue.
# format RAILS_ENV=production bundle exec rake migrations:merge_duplicate_people person_to_keep='person_mongo_id' person_to_remove='person_mongo_id'

namespace :migrations do 
  desc "Merge Two Policies"
  MergeTwoPolicies.define_task :merge_two_policies => :environment
end