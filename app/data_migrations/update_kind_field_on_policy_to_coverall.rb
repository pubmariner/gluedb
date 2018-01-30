require File.join(Rails.root, "lib/mongoid_migration_task")

class UpdateKindFieldOnPolicyToCoverall < MongoidMigrationTask

  def migrate
    hbx_ids = ENV['hbx_ids'].to_s.split(',')
    policies = []
    hbx_ids.each do |hbx_id|
      policy = Policy.where(:hbx_enrollment_ids => hbx_id).first
      policy.update_attributes!(kind: "coverall")
      policies << policy.id
    end

    # quick sanity check
    if (hbx_ids.size != policies.size)
      raise ArgumentError, 'Not all the policies that need to be updated were found.'
    end
  end
end