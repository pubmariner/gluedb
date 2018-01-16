require File.join(Rails.root, "lib/mongoid_migration_task")

class ChangeDependentRelationship < MongoidMigrationTask
  def migrate
    policy = Policy.where(eg_id: ENV['eg_id']).first
    if policy.nil?
      puts "Policy is not found with given eg_id#{ENV['eg_id']}" unless Rails.env.test?
    else
      policy.enrollees.each do |enrollee|
        if enrollee.m_id == ENV['hbx_member_id']
          enrollee.update_attributes(rel_code:ENV['new_relationship_type'])
          if enrollee.rel_code == ENV['new_relationship_type']
            puts "Changed relatiosnhip type for enrollee  #{ENV['hbx_member_id']} to #{ENV['new_relationship_type']}" unless Rails.env.test?
          else
            puts "Can not change relatiosnhip type for enrollee  #{ENV['hbx_member_id']}" unless Rails.env.test?
          end
          return
        end
      end
      puts "Enrollee is not found with given hbx_member_id #{ENV['hbx_member_id']}" unless Rails.env.test?
    end
  end
end