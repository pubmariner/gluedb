class NewEnrollment

  def initialize(update_person_uc, create_policy_uc)
    @update_person_use_case = update_person_uc
    @create_policy_use_case = create_policy_uc
  end

  def execute(request, listener)
    failed = false
    individuals = request[:individuals]
    policies = request[:policies]
    if individuals.blank?
      listener.no_enrollees
      listener.fail
      return
    else
      failed = failed || !(individuals.all? do |ind|
        @update_person_use_case.validate(ind, listener)
      end)
    end
    if policies.blank?
      listener.no_policies
      listener.fail
      return
    else
      failed = failed || !(policies.all? do |ind|
        @create_policy_use_case.validate(ind, listener)
      end)
    end

    if failed
      listener.fail
    else
      individuals.each do |ind|
        @update_person_use_case.commit(ind)
      end
      policies.each do |pol|
        @create_policy_use_case.commit(pol)
      end
      listener.success
    end
  end

end
