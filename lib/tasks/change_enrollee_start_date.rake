require File.join(Rails.root,"app","data_migrations","change_enrollee_start_date.rb")

# This rake tasks changes coverage start dates for  members of a policy in Glue. 
# In the below rake task, enrollee_mongo_is an optional field that can be used when there are multiple enrollees with the same hbx member ID.
#  RAILS_ENV=production bundle exec rake migrations:change_enrollee_start_date eg_id='123456' enrollee_mongo_id='s3d9fws8923' m_id='234' start_date='01/01/2017'  new_start_date='05/01/2017'

namespace :migrations do 
  desc "Change Enrollee coverage start date"
  ChangeEnrolleeStartDate.define_task :change_enrollee_start_date => :environment
end

