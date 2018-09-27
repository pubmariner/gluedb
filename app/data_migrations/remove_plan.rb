# Removes plans
require File.join(Rails.root, "lib/mongoid_migration_task")

class RemovePlan < MongoidMigrationTask

  def migrate
    hios_plan_id = ENV['hios_plan_id']
    plan = Plan.where(hios_plan_id: hios_plan_id).first 
    if plan.present? 
      begin 
        plan.destroy
        puts 'Plan has been deleted'
      rescue Exception => e
        puts e.message unless Rails.env.test?
      end
    else
      puts "Could not find a plan with that hios_id" unless Rails.env.test?
    end
  end

end