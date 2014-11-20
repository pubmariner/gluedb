class ApplicantLink
  include Mongoid::Document

  embedded_in :tax_household
  embedded_in :financial_statement
  embedded_in :eligibility_determination
  embedded_in :hbx_enrollment
  embedded_in :hbx_enrollment_exemption
  embedded_in :qualifying_life_event

  field :person_id, type: Moped::BSON::ObjectId
  field :tax_household_id, type: Moped::BSON::ObjectId
  field :financial_statement_id, type: Moped::BSON::ObjectId

  field :is_primary_applicant, type: Boolean

  field :is_ia_eligible, type: Boolean, default: false
  field :is_medicaid_chip_eligible, type: Boolean, default: false

  field :is_active, type: Boolean, default: true

  def parent
    raise "undefined parent ApplicationGroup" unless application_group? 
    self.application_group
  end

  def person=(person_instance)
    return unless person_instance.is_a? Person
    self.person_id = person_instance._id
    # parent.applicants << person_instance  # Applicant associations are tracked at ApplicationGroup level
  end

  def person
    Person.find(self.person_id) unless self.person_id.blank?
  end

  def is_active?
    self.is_active
  end

end