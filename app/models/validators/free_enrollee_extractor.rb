module Validators
  class FreeEnrolleeExtractor
    def initialize
      @ceiling = 3
    end

    def extract_free_from(collection)
      enrollees = Collections::Enrollees.new(collection)

      children = enrollees.children
      if(children.count > @ceiling)
        sorted = sort_by_oldest(children.to_a)
        sorted.shift(children.count - @ceiling)
        Collections::Enrollees.new(sorted).within_age_range(0...21).to_a
      else
        []
      end
    end

    def sort_by_oldest(enrollees)
      enrollees.sort! { |x, y| y.age <=> x.age }
    end
  end
end
