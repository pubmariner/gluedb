class AddEligibilites
  def self.import!(person, aes)
    aes.each do |requested_eligibility|
      eligibility = AssistanceEligibility.new(requested_eligibility)   
      if person.assistance_eligibilities.any? { |e| e.submission_date == requested_eligibility[:submission_date]} 
        next
      end
      person.assistance_eligibilities << eligibility
    end

    person.save!
  end
end
