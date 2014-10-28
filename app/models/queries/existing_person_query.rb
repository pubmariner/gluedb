module Queries
  class ExistingPersonQuery
    include SimpleConverters

    def initialize(ssn, first_name, birth_date)
      @ssn = ssn
      @first_name = first_name
      @birth_date = birth_date
    end

    def find
      people = Person.unscoped.where({"members.ssn" => @ssn})
      return nil if people.empty?

      member = matching_members_of(people).first
      member.nil? ? nil : member.person
    end

    private

    def matching_members_of(people)
      members = people.map do |p|
        p.members.select { |m| m.ssn == @ssn }
      end.flatten(1)

      filters = member_filters(@birth_date, @first_name)
      members.select! do |mm|
        filters.all? { |s| s.call(mm) }
      end
      members
    end

    def member_filters(birth_date, n_f)
      [ Proc.new { |m|
          date_string(m.dob) == birth_date
        },
        Proc.new { |m|
          safe_downcase(m.person.name_first) == safe_downcase(n_f)
        }
      ]
    end
  end
end
