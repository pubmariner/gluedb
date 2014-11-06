class EnrollmentExemption
  include Mongoid::Document
  include Mongoid::Timestamps

  # KIND = %w[]

  field :certificate_number, type: String
  field :kind, type: String
  field :start_date, type: Date
  field :end_date, type: Date

  embedded_in :tax_household

end
