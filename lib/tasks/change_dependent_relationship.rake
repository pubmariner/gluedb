require File.join(Rails.root,"app","data_migrations","change_dependent_relationship.rb")

# This rake task change the relationship type of an enrollee member of a policy in Glue.
#the valid relationship types: "self", "spouse", "child", "ward", "life partner"
# format RAILS_ENV=production bundle exec rake migrations:change_dependent_relationship eg_id='policy_hbx_id' hbx_member_id='person_hbx_id' new_relationship_type='child'

namespace :migrations do
  desc "Change dependent relationship"
  ChangeDependentRelationship.define_task :change_dependent_relationship => :environment
end