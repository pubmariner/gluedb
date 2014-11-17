class ApplicantLink
  include Mongoid::Document

  embedded_in :tax_household
  embedded_in :hbx_enrollment
  embedded_in :hbx_enrollment_exemption
  embedded_in :eligibility_determination

  field :person_id, type: Moped::BSON::ObjectId
  field :is_primary_applicant, type: Boolean
  field :is_active, type: Boolean, default: true

  field :is_ia_eligible, type: Boolean, default: false
  field :is_medicaid_chip_eligible, type: Boolean, default: false

  def person=(person_instance)
    return unless person_instance.is_a? Person
    self.person_id = person_instance._id
  end

  def person
    Person.find(self.person_id) unless self.person_id.blank?
  end

end