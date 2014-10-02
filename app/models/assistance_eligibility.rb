class AssistanceEligibility
  include Mongoid::Document
  include Mongoid::Timestamps

  TAX_FILING_STATUS_TYPES = %W[tax_filer tax_dependent non_filer]
  
  field :is_primary_applicant, type: Boolean
  # field :is_enrolled_for_coverage, type: Boolean  # Coverage or HH eligibility determination only

  field :tax_filing_status, type: String
  field :is_tax_filing_together, type: Boolean

  field :is_enrolled_for_es_coverage, type: Boolean
  field :is_without_assistance, type: Boolean

  field :is_ia_eligible, type: Boolean
  field :is_medicaid_chip_eligible, type: Boolean
  field :submission_date, type: Date

  index({submission_date:  1})

  embedded_in :person

  embeds_many :incomes
  embeds_many :deductions
  embeds_many :alternate_benefits

  validates :tax_filing_status, 
    inclusion: { in: TAX_FILING_STATUS_TYPES, message: "%{value} is not a valid tax filing status" }, 
    allow_blank: true

  def is_receiving_benefit
    #look in alt benefits...if any are in this year...return true
  end
end
