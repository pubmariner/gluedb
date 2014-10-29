class ChangeEffectiveDate
  def initialize(transmitter, policy_repo = Policy)
    @policy_repo = policy_repo
    @transmitter = transmitter
  end

  def execute(request, listener)
    # policy = @policy_repo.find(request[:policy_id])
    
    policy = @policy_repo.where({"_id" => request[:policy_id]}).first

    if(policy.nil?)
      listener.no_such_policy(policy_id: request[:policy_id])
      listener.fail
      return
    end

    if(policy.subscriber.coverage_start == Date.parse(request[:effective_date]))
      listener.no_changes_needed(policy_id: request[:policy_id])
      listener.fail
      return
    end

    if policy.subscriber.coverage_ended?
      listener.policy_inactive(policy_id: request[:policy_id])
      listener.fail
      return
    end

    terminateds = terminated_enrollees(policy)
    if terminateds.any?
      listener.ambiguous_terminations({:policy_id => request[:policy_id], :member_ids => terminateds.map(&:m_id)})
      listener.fail
      return
    end

    coverage_starts = policy.enrollees.reject { |en| cancelled?(en) }.map(&:coverage_start)

    if coverage_starts.uniq.length > 1
      listener.start_date_mismatch({:policy_id => request[:policy_id], :coverage_start => coverage_starts})
      listener.fail
      return
    end

    affected_enrollees = []
    policy.enrollees.each do |enrollee|
      unless enrollee.coverage_ended?
        enrollee.coverage_start = Date.parse(request[:effective_date])

        rate_period_date = nil
        if (policy.market == 'individual')
          rate_period_date = enrollee.coverage_start
        elsif (policy.market == 'shop')
          rate_period_date = policy.employer.plan_year_start
        end
        enrollee.pre_amt = policy.plan.rate(rate_period_date, enrollee.coverage_start, enrollee.member.dob).amount
        affected_enrollees << enrollee
      end
    end

    #reverse engineer the employer contribution
    employer_contribution_percentage = policy.employer_contribution / policy.total_premium_amount

    # calculate new total
    subscriber = policy.subscriber
    total = 0
    policy.enrollees.each do |enrollee|
      if enrollee.coverage_end == subscriber.coverage_end
        total += enrollee.pre_amt 
      end
    end
    policy.total_premium_amount = total

    #update responsible amount
    policy.total_responsible_amount = policy.total_premium_amount - total_credit_adjustment(policy, employer_contribution_percentage)

    transmit_request = {
      policy_id: policy.id,
      operation: 'change',
      reason: 'benefit_selection',
      affected_enrollee_ids: affected_enrollees.map(&:m_id),
      include_enrollee_ids: affected_enrollees.map(&:m_id),
      current_user: request[:current_user]
    }
    policy.save!
    @transmitter.execute(transmit_request)
    listener.success
  end

  private
  def total_credit_adjustment(policy, percent)
    policy.employer_contribution = (policy.total_premium_amount * percent).truncate(2)
  end

  def cancelled?(enrollee)
    enrollee.coverage_start == enrollee.coverage_end
  end

  def terminated_enrollees(policy)
    policy.enrollees.select do |e|
      !e.coverage_end.blank? && (e.coverage_start != e.coverage_end)
    end
  end
end
