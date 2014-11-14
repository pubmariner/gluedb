class ApplicantLink
  include Mongoid::Document

  embedded_in :tax_household
  embedded_in :hbx_enrollment
  embedded_in :eligibility_determinations

  field :person_id, type: Moped::BSON::ObjectId
  field :is_active, type: Boolean, default: true

  def person=(person_instance)
    return unless person_instance.is_a? Person
    self.person_id = person_instance._id
  end

  def person
    Person.find(self.person_id) unless self.person_id.blank?
  end

end