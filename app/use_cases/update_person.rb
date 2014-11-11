class UpdatePerson

  def initialize
    @create_person_factory = CreatePerson.new
    @person_repo = Person
    address_changer = ChangeMemberAddress.new(nil)
    @update_person_address_factory = UpdatePersonAddress.new(Person, address_changer, ChangeAddressRequest)
  end

  def validate(request, listener)
    fail = false

    begin
      options = {
        member_id: request[:member_id],
        name_first: request[:names][:name_first],
        name_last: request[:names][:name_last],
        ssn: request[:members][0][:ssn],
        dob: request[:members][0][:dob]
      }

      [person, member] = PersonMatchStrategies::Finder.find_person_and_member(options)

      if person.blank?
        return @create_person_factory.validate(request, listener)
      end

      person.assign_attributes(request[:names])
      person.attributes = { 
        job_title: request[:job_title], 
        department: request[:department],
        is_active: request[:is_active]
      }

      return false unless person.valid?

      member ||= person.members.new
      member.attributes = request[:members][0]
      return false unless member.valid?

      fail = !@update_person_address_factory.validate(request, listener)

      request[:emails].each do |email|
        if !person.emails.new(email).valid?
          return false
        end
      end

      request[:phones].each do |phone|
        if !person.phones.new(phone).valid?
          return false
        end
      end
      
      request[:relationships].each do |relationship|
        if !person.person_relationships.new(relationship).valid?
          return false
        end
      end

    rescue PersonMatchStrategies::AmbigiousMatchError => error
      listener.person_match_error(error.message)
    end

    !fail
  end

  def execute(request, listener)
    if validate(request, listener)
      commit(request)
      listener.success
    else
      listener.fail
    end
  end

  def commit(request)
  end
end