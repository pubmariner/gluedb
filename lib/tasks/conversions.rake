require File.join(Rails.root,"app","data_migrations","conversions.rb")

# This rake task updates the kind field for the given policy to "coverall".
# format RAILS_ENV=production bundle exec rake migrations:create_aptc_credits eg_id="abc123" start_on="1/1/2018" end_on="2/3/108" aptc=100.0 pre_amt_tot=2222 tot_res_amt=123

namespace :migrations do
  desc "Generates CV2s and transforms them in to x12s and CV1s "
  Conversions.define_task :conversions => :environment
end