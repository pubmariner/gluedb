module Queries
  class PoliciesWithNoFamilies
    def initialize
    end

    # returns ids of policies that do not belong to any family
    def execute
      policies_with_hbx_enrollment = Family.all.inject([]) do |policies, family|
        begin
          policies << family.active_household.hbx_enrollments.where(:kind.ne => 'employer_sponsored').pluck(&:policy_id)
          policies.flatten!
        rescue => e
          puts e
        end
        policies
      end

      Policy.where(:id.nin => policies_with_hbx_enrollment).pluck(:id)
    end
  end
end
