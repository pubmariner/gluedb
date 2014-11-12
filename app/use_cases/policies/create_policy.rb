module Policies
  class CreatePolicy

    def validate(request, listener)
      failed = false
      eg_id = request[:enrollment_group_id]
      hios_id = request[:hios_id]
      plan_year = request[:plan_year]
      broker_npn = request[:broker_npn]
      existing_policy = Policy.find_for_group_and_hios(eg_id, hios_id)
      if !existing_policy.blank?
        listener.policy_already_exists({
          :enrollment_group_id => eg_id,
          :hios_id => hios_id
        })
        fail = true
      end
      plan = Plan.find_by_hios_id_and_year(hios_id, plan_year)
      if plan.blank?
        listener.plan_not_found(:hios_id => hios_id, :plan_year => plan_year)
        fail = true
      end
      if !broker_npn.blank?
        broker = Broker.find_by_npn(broker_npn)
        if broker.blank?
          listener.broker_not_found(:npn => broker_npn)
          fail = true
        end
      end
      !fail
    end
  end
end
