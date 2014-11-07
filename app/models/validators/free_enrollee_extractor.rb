module Validators
  class FreeEnrolleeExtractor
    def initialize
      @ceiling = 3
    end

    def extract_free_from(collection)
      enrollees = Collections::Enrollees.new(collection)

      children = enrollees.children
      children_under_21 = Collections::Enrollees.new(children).within_age_range(0...21).to_a
      if(children_under_21.count > @ceiling)
        sorted = sort_by_oldest(children_under_21)
        sorted.shift(@ceiling)
        Collections::Enrollees.new(sorted).to_a
      else
        []
      end
    end

    def sort_by_oldest(enrollees)
      enrollees.sort! { |x, y| y.age <=> x.age }
    end
  end
end
