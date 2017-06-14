require File.join(Rails.root,"app","data_migrations","remove_carrier.rb")

# This rake task is to remove carrier objects from Glue, as well associatd plans and carrier profiles.
namespace :migrations do
  desc "Removing Carrier"
  RemoveCarrier.define_task :remove_carrier => :environment
end