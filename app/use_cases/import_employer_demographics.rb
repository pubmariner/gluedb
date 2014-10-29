class ImportEmployerDemographics
  def execute(xml)
    employers = EmployerFactory.new.create_many_from_xml(xml)
    employers.each do |e|
      Employer.create_from_group_file(e)
    end
  end
end
