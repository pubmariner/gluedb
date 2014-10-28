class AddEligibilities
  def self.import!(person, aes)

    aes.each do |requested_eligibility|
      eligibility = AssistanceEligibility.new(requested_eligibility)   
      if person.assistance_eligibilities.any? { |e| e.submission_date == requested_eligibility[:submission_date]} 
        next
      end
      person.assistance_eligibilities << eligibility
    end

    bad_aes = person.assistance_eligibilities.reject(&:valid?)
    if bad_aes.any?
      eligibility = bad_aes.first
      bad_incomes = eligibility.incomes.reject(&:valid?)
      bad_deductions = eligibility.deductions.reject(&:valid?)
      bad_alts = eligibility.alternate_benefits.reject(&:valid?)
      if bad_incomes.any?
        raise aes.inspect
        raise bad_incomes.first.errors.inspect
      end
      if bad_deductions.any?
        raise bad_deductions.first.errors.inspect
      end
      if bad_alts.any?
        raise bad_alts.first.errors.inspect
      end
      raise bad_aes.first.errors.inspect
    end

    person.save!
  end
end
