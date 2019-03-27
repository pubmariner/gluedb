# Changes an Enrollee's Member ID 
require File.join(Rails.root, "lib/mongoid_migration_task")

class ChangeEnrolleeMemberId < MongoidMigrationTask

  def migrate
    if Policy.where(eg_id: ENV['policy_id']).first.present? && ENV['eg_id'].blank?
      raise "The policy ID you supplied is also an enrollment group ID. Please double-check that your policy ID is not an enrollment group ID."
    end

    if ENV['policy_id'].present?
      policy = Policy.find(ENV['policy_id'])
    else
      policy = Policy.where(eg_id: ENV['eg_id']).first
    end

    (raise "This policy cannot be found." if policy.blank?) unless Rails.env.test?
    enrollee = policy.enrollees.detect{|en| en.m_id == ENV['old_hbx_id']}
    (raise "This enrollee cannot be found." if enrollee.blank?) unless Rails.env.test? 
    enrollee.update_attributes(:m_id => ENV['new_hbx_id'])
    puts "Member ID of Enrollee was changed from #{ENV['old_hbx_id']} to #{enrollee.m_id}" unless Rails.env.test?

    c = Comment.new(content: "HBX ID for Policy #{policy.eg_id} was changed from #{ENV['old_hbx_id']} to #{ENV['new_hbx_id']}",
                    user: "system", created_at: Time.now,updated_at: Time.now)
    enrollee.person.comments << c
    c.save
  end
end