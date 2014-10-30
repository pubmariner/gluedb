class DeleteAddress
  def initialize(transmitter, person_repo = Person, eligible_policies = ChangeAddress::EligiblePolicies)
    @person_repo = person_repo
    @transmitter = transmitter
    @eligible_policies = eligible_policies
  end

  def commit(request)
    person = @person_repo.find_by_id(request[:person_id])

    existing_address = person.address_of(request[:type])

    if existing_address.nil?
      return
    end

    policies = @eligible_policies.for_person(person)

    policies.each_affected_group(request[:type]) do |policy, affected_enrollees, included_enrollees|

      people = affected_enrollees.map { |e| e.person }

      people.each do |person|
        person.remove_address_of(request[:type])
        person.save!
      end

      # TODO: Operation/Reason constant cleanup
      transmit_request = {
        policy_id: policy.id,
        operation: 'change',
        reason: 'change_of_location',
        affected_enrollee_ids: affected_enrollees.map(&:m_id),
        include_enrollee_ids: included_enrollees.map(&:m_id),
        current_user: request[:current_user]
      }

      if(['home', 'mailing'].include?(request[:type]))
        @transmitter.execute(transmit_request)
      end
    end
  end
end
