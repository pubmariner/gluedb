module Queries
  class PersonMatch
    def self.find(options)
      found_person = nil
      found_people = Person.where({"members.ssn" => options[:ssn]})
      if (found_people.length > 0)
        if (!options[:name_last].nil?)
          filtered = found_people.select { |per| per.name_last.downcase == options[:name_last].downcase }
          found_person = more_than_one_is_none(filtered)
        else
          found_person = more_than_one_is_none(found_people)
        end
      end
      if (found_person.nil?)
        found_people = Person.where({"members.dob" => options[:dob], "name_first" => options[:name_first], "name_last" => options[:name_last]})
        found_person = more_than_one_is_none(found_people)
      end
      found_person
    end

    def self.more_than_one_is_none(col)
      col.many? ? nil : col.first
    end

  end
end
