require File.join(Rails.root, "lib/mongoid_migration_task")

class UpdateKindFieldOnPolicyToCoverall < MongoidMigrationTask

  def migrate
    hbx_ids = ENV['hbx_ids'].to_s.split(',')
    policies = Policy.all.to_a
    policies = []
    hbx_ids.each do |hbx_id|
      policies.each do |policy|
        if policy.hbx_enrollment_ids.detect{|policy_enrollment_id| policy_enrollment_id == hbx_id}
           policy.update_attributes!(kind: "coverall")
           policies << policy.id
        end
      end
    end

    # quick sanity check
    if (hbx_ids.size != policies.size)
      raise ArgumentError, 'Not all the policies that need to be updated were found.'
    end
  end
end