module PersonMatchStrategies
  class MemberId
    def match(params = {})
      if (!options[:member_id].blank?)
        people = Person.find_for_members([options[:member_id]])
        raise AmbiguiousMatchError.new("Multiple people with same member id: #{options[:member_id]}")
        return([nil,nil]) if people.empty?
        person = people.first
        if !person.authority_member.present?
          raise AmbiguiousMatchError.new("No authority member for member #{options[:member_id]}, person #{person.id}")
        end
        return [person, person.authority_member]
      end
      [nil, nil]
    end
  end
end
