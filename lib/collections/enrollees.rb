module Collections
  class Enrollees < Collection
    def currently_active
      items.select { |e| e.coverage_status == 'active' }
    end

    def shares_addresses_with(person)
      items.select { |enrollee| enrollee.person.addresses_match?(person) }
    end

    def children
      items.select { |e| e.rel_code == 'child' }
    end

    def within_age_range(range)
      items.select { |e| range.cover?(e.age) }
    end
  end
end
