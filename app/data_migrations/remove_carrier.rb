# Removes Carriers, Carrier Profiles, and Plans Associated with Carriers
require File.join(Rails.root, "lib/mongoid_migration_task")

class RemoveCarrier < MongoidMigrationTask
  def remove_carrier
  end

  def remove_plans
  end

  def migrate
    remove_plans
    remove_carrier
  end
end