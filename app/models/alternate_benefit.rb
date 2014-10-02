class AlternateBenefit
  include Mongoid::Document
  include Mongoid::Timestamps

  KINDS = %W(
		acf_refugee_medical_assistance
		americorps_health_benefits
		child_health_insurance_plan
		medicaid
		medicare
		medicare_advantage
  	medicare_part_b
		private_individual_and_family_coverage
		state_supplementary_payment
		tricare
		veterans_benefits
	)

  field :kind, type: String
  field :start_date, type: Date
  field :end_date, type: Date
  field :submission_date, type: Date

  embedded_in :assistance_applicant

  validates :kind, presence: true, 
  						inclusion: { in: KINDS, message: "%{value} is not a valid alternative benefit type" }
  validates :start_date, presence: true

end
