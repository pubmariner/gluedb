class UpdatePolicyStatus

  def initialize(policy_repo)
    @policy_repo = policy_repo
  end

  def execute(request, listener)
    policy = @policy_repo.find_by_id(request[:policy_id])

    failed = false

    if(policy.nil?)
      listener.policy_not_found(request[:policy_id])
      failed = true
      listener.fail
      return
    end

    if(policy.subscriber.m_id != request[:subscriber_id])
      listener.subscriber_id_mismatch(request[:policy_id])
      failed = true
    end

    if(policy.enrollees.count != request[:enrolled_count])
      listener.enrolled_count_mismatch
      failed = true
    end

    if(policy.plan.hios_plan_id != request[:hios_plan_id])
      listener.plan_mismatch
      failed = true
    end

    if(request[:end_date] < request[:begin_date])
      listener.invalid_dates({begin_date: request[:begin_date], end_date: request[:end_date]})
      failed = true 
    end

    if(request[:status] == 'terminated')
      if(request[:begin_date] == request[:end_date])
        listener.invalid_dates({begin_date: request[:begin_date], end_date: request[:end_date]})
        failed = true
      end
    end

    if(request[:status] == 'canceled')
      if(request[:begin_date] != request[:end_date])
        listener.invalid_dates({begin_date: request[:begin_date], end_date: request[:end_date]})
        failed = true
      end
    end

    if (request[:status] == policy.aasm_state)
      listener.policy_status_is_same
      failed = true
    end

    if(failed)
      listener.fail
      return
    end

    policy.aasm_state = request[:status]
    policy.save
    listener.success
  end
end
