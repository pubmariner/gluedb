class UpdatePersonRequest
  def from_cv(payload)
    parser = Nokogiri::XML(payload)
    individual = Parsers::Xml::Reports::individual.new(parser.root)

    request = {
      person_id: individual.id,
      member_id: individual.person.id,
      names: person_names(individual), 
      is_active: individual.is_active,
      members: [member_details(individual)], 
      addresses: individual.person.addresses.map{|address| address.marshal_dump},
      emails: individual.person.emails.map{|email| email.marshal_dump},
      relationships: individual.relationships.map{|relationship| relationship.marshal_dump},
      job_title: individual.person.job_title,
      department: individual.person.department,
      is_active: individual.root_elements.is_active
    }

    request
  end

  def person_names(individual)
    {
      name_pfx: individual.names.person_name_prefix_text,
      name_first: individual.names.person_given_name,
      name_middle: individual.names.person_middle_name,
      name_last: individual.names.person_surname,
      name_sfx: individual.names.person_name_suffix_text,
      name_full: individual.names.person_full_name,
      alternate_name: individual.names.person_alternate_name
    }
  end

  def member_details(individual)
    {
      ssn: individual.demographics.ssn,
      gender: individual.demographics.sex,
      dob: individual.demographics.birth_date,
      ethnicity: individual.demographics.ethnicity,
      race: individual.demographics.race,
      birth_location: individual.demographics.birth_location,
      citizen_status: individual.demographics.citizen_status,
      is_state_resident: individual.demographics.is_state_resident,
      is_incarcerated: individual.demographics.is_incarcerated
    }
  end
end
