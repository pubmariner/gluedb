class UpdatePolicyStatus

  def initialize(policy_repo)
    @policy_repo = policy_repo
    @allowed_statuses = ['effectuated', 'carrier_canceled', 'carrier_terminated']
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

    subscriber = policy.subscriber

    if(policy.subscriber.m_id != request[:subscriber_id])
      listener.subscriber_id_mismatch({provided: request[:subscriber_id], existing: policy.subscriber.m_id})
      failed = true
    end

    if(policy.enrollees.length != request[:enrolled_count])
      listener.enrolled_count_mismatch({provided: request[:enrolled_count], existing: policy.enrollees.length})
      failed = true
    end

    if(policy.plan.hios_plan_id != request[:hios_plan_id])
      listener.plan_mismatch({provided: request[:hios_plan_id], existing: policy.plan.hios_plan_id})
      failed = true
    end

    if(!request[:end_date].nil? && request[:end_date] < request[:begin_date])
      listener.invalid_dates({begin_date: request[:begin_date], end_date: request[:end_date]})
      failed = true 
    end

    if(request[:status] == 'carrier_terminated')
      if(request[:begin_date] == request[:end_date])
        listener.invalid_dates({begin_date: request[:begin_date], end_date: request[:end_date]})
        failed = true
      end
    end

    if(request[:status] == 'carrier_canceled')
      if(request[:begin_date] != request[:end_date])
        listener.invalid_dates({begin_date: request[:begin_date], end_date: request[:end_date]})
        failed = true
      end
    end

    if (request[:status] == policy.aasm_state)
      listener.policy_status_is_same
      failed = true
    end

    if (!@allowed_statuses.include?(request[:status]))
      listener.invalid_status({provided: request[:status], allowed: @allowed_statuses})
      failed = true
    end

    policy.enrollees.each do |e|
      if(subscriber.coverage_end != e.coverage_end)
        listener.enrollee_end_date_is_different
        failed = true
      end
    end

    if(failed)
      listener.fail
      return
    end

    if(subscriber.active?)
      if(request[:status] == 'carrier_canceled' || request[:status] == 'carrier_terminated')
        policy.enrollees.each do |e|
          e.coverage_end = request[:end_date]
          e.coverage_status = 'inactive'
        end
      end
    else

      case request[:status]
        when 'effectuated'
          policy.enrollees.each do |e|
            e.coverage_end = nil
            e.coverage_status = 'active'
          end
        when 'carrier_terminated'
          policy.enrollees.each do |e|
            e.coverage_end = request[:end_date]
            e.coverage_status = 'inactive'
          end
        when 'carrier_canceled'
          policy.enrollees.each do |e|
            e.coverage_end = request[:end_date]
            e.coverage_status = 'inactive'
          end
      end
    end

    policy.aasm_state = request[:status]
    policy.save
    listener.success
  end

end
