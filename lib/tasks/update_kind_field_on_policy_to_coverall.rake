require File.join(Rails.root,"app","data_migrations","update_kind_field_on_policy_to_coverall.rb")

# This rake task updates the kind field on Glue policies to coverall for Glue policies that represent
# valid coveall enrollments in EA
# The hbx_ids to search for will be passed as an environment variable
# format RAILS_ENV=production bundle exec rake migrations:update_kind_field_on_policy_to_coverall hbx_ids='onehbxid,anotherhbxid,etchbxid'

namespace :migrations do
  desc "Update kind field on policy to coverall"
  UpdateKindFieldOnPolicyToCoverall.define_task :update_kind_field_on_policy_to_coverall => :environment
end