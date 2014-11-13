class ApplicantLink
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :tax_household
  embedded_in :hbx_enrollment
  embedded_in :eligibility_determinations

  field :person_id, type: Moped::BSON::ObjectId
  field :is_active, type: Boolean, default: true

end