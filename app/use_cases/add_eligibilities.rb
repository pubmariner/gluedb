class AddEligibilites
  def initialize(person_repo)
    @person_repo = person_repo
  end

  def execute(request)
    person = @person_repo.find_by_id(request[:person_id])

    request[:assistance_eligibilities].each do |requested_eligibility|
      eligibility = AssistanceEligibility.new(requested_eligibility)   
      if person.assistance_eligibilities.any? { |e| e.submission_date == requested_eligibility[:submission_date]} 
        next
      end
      person.assistance_eligibilities << eligibility
    end

    person.save!
  end
end
