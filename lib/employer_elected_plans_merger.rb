module EmployerElectedPlansMerger
  def self.merge(existing, incoming)
    existing_hash = existing.elected_plans.inject({}) do |acc, val|
      acc[val.qhp_id] = val
      acc
    end
    existing_ids = existing_hash.keys
    existing_plans, new_plans = incoming.elected_plans.partition { |pl| existing_ids.include?(pl.qhp_id) }
    existing.elected_plans.concat(new_plans)
    existing_plans.each do |plan|
      existing_plan = existing_hash[plan.qhp_id]
      if !existing_plan.nil?
        existing_plan.merge_without_blanking(plan,
          :carrier_employer_group_id,
          :carrier_policy_number,
          :coverage_type,
          :qhp_id,
          :hbx_plan_id,
          :plan_name,
          :metal_level,
          :original_effective_date,
          :renewal_effective_date)
      end
      existing_plan.touch
    end
    existing.save!
  end
end
