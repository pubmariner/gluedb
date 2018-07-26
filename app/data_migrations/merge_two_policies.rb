require 'pry'
require File.join(Rails.root, "lib/mongoid_migration_task")

class MergeTwoPolicies < MongoidMigrationTask

  def migrate 

    
    policy_to_keep = Policy.where(eg_id: ENV['policy_to_keep']).first
    policy_to_remove = Policy.where(eg_id: ENV['policy_to_remove']).first
    tot_res_amt = Policy.where(eg_id:ENV['policy_of_final_tot_res_amt']).first.tot_res_amt
    pre_amt_tot = Policy.where(eg_id:ENV['policy_of_final_pre_amt_tot']).first.pre_amt_tot
    tot_emp_res_amt = Policy.where(eg_id:ENV['policy_of_final_tot_emp_res_amt']).first.tot_emp_res_amt
    rating_area = Policy.where(eg_id:ENV['policy_of_final_rating_area']).first.rating_area
    composite_rating_tier = Policy.where(eg_id:ENV['policy_of_final_composite_rating_tier']).first.composite_rating_tier
    
    existing_enrollees = policy_to_keep.enrollees.map(&:m_id)
    enrollees_to_move = policy_to_remove.enrollees.where(:m_id => {"$nin" => existing_enrollees}).to_a
    policy_to_keep.enrollees << enrollees_to_move
    policy_to_keep.hbx_enrollment_ids << policy_to_remove.hbx_enrollment_ids
    policy_to_keep.update_attributes!(
      pre_amt_tot: pre_amt_tot,
      tot_emp_res_amt: tot_emp_res_amt,
      tot_res_amt: tot_res_amt,
      rating_area: rating_area,
      composite_rating_tier: composite_rating_tier)

    policy_to_keep.hbx_enrollment_ids.uniq!
    policy_to_keep.hbx_enrollment_ids.flatten!
    policy_to_keep.save!


    policy_to_remove.update_attributes!(eg_id: "#{policy_to_remove.eg_id} - DO NOT USE")

    
    policy_to_remove.hbx_enrollment_ids.each do |id|      
      policy_to_remove.hbx_enrollment_ids.clear.push("#{id} - DO NOT USE")
    end
    
    
  end


end