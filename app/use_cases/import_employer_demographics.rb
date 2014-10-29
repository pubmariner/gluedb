class NullListener
  def invalid_employer
  end

  def fail
  end

  def success
  end
end

class ImportEmployerDemographics
  def execute(xml)
    create_employer = CreateEmployer.new(NullListener.new, Employer, PlanYear, Address, Email, Phone, Broker)
    update_employer = UpdateEmployer.new(Employer, Address, Phone, Email, PlanYear)

    requests = EmployerRequest.many_from_xml(xml)
    requests.each do |request|
      if (Employer.find_for_fein(request[:fein]))
        puts "Updating Employer \"#{request[:name]}\"(fein:#{request[:fein]})"
        update_employer.execute(request)
      else
        puts "Creating Employer \"#{request[:name]}\"(fein:#{request[:fein]})"
        create_employer.execute(request)
      end
    end
  end
end
