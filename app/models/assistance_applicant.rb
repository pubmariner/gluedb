class AssistanceApplicant
  include Mongoid::Document
  include Mongoid::Timestamps

  TAX_FILING_STATUS_TYPES = %W[tax_filer tax_dependent non_filer]
  field :is_primary_applicant, type: Boolean
  field :consent_applicant_id, type: String
  field :is_enrolled_for_coverage, type: Boolean	# Coverage or HH eligibility determination only

  field :tax_filing_status, type: String
  field :is_tax_filing_together, type: Boolean
  field :is_incarcerated, type: Boolean, default: false

  field :is_without_assistance, type: Boolean
  field :is_ia_eligible, type: Boolean
  field :is_medicaid_chip_eligible, type: Boolean

  field :is_receiving_benefit, type: Boolean
  field :projected_amount_in_cents, type: Integer

  belongs_to :person
  embedded_in :household

  embeds_many :alternative_benefits
  embeds_many :incomes
  embeds_many :deductions

  validates :tax_filing_status, 
    inclusion: { in: TAX_FILING_STATUS_TYPES, message: "%{value} is not a valid tax filing status" }, 
    allow_blank: true

end
