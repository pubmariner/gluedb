require File.join(Rails.root, "lib/mongoid_migration_task")

class MergeTwoPolicies < MongoidMigrationTask
  
  first_policy = Policy.where(eg_id: ENV['first_policy']).first
  second_policy = Policy.where(eg_id: ENV['second_policy']).first


end