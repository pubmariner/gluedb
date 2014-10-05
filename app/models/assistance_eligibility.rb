require 'active_support/time'

class AssistanceEligibility
  include Mongoid::Document
  include Mongoid::Timestamps

  TAX_FILING_STATUS_TYPES = %W(tax_filer tax_dependent non_filer)
  
  field :is_primary_applicant, type: Boolean
  # field :is_enrolled_for_coverage, type: Boolean  # Coverage or HH eligibility determination only

  field :tax_filing_status, type: String
  field :is_tax_filing_together, type: Boolean

  field :is_enrolled_for_es_coverage, type: Boolean, default: false
  field :is_without_assistance, type: Boolean, default: true

  field :is_ia_eligible, type: Boolean, default: false
  field :is_medicaid_chip_eligible, type: Boolean, default: false
  field :submission_date, type: Date

  index({submission_date:  1})

  embedded_in :person

  embeds_many :incomes
  embeds_many :deductions
  embeds_many :alternate_benefits

  accepts_nested_attributes_for :incomes
  accepts_nested_attributes_for :deductions
  accepts_nested_attributes_for :alternate_benefits

  validates :tax_filing_status, 
    inclusion: { in: TAX_FILING_STATUS_TYPES, message: "%{value} is not a valid tax filing status" }, 
    allow_blank: true

  def is_receiving_benefit?
    #look in alt benefits...if any are in this year...return true

    return_value = false

    alternate_benefits.each do |alternate_benefit|
      return_value = is_receiving_benefits_this_year?(alternate_benefit)
      break if return_value
    end

    return return_value
  end

  def compute_yearwise(incomes_or_deductions)

    income_deduction_per_year = Hash.new(0)


    incomes_or_deductions.each do |income_deduction|

      working_days_in_year = Float(52*5)

      daily_income = 0

      case income_deduction.frequency
        when "daily"
          daily_income = income_deduction.amount_in_cents
        when "weekly"
          daily_income = income_deduction.amount_in_cents / (working_days_in_year/52)
        when "biweekly"
          daily_income = income_deduction.amount_in_cents / (working_days_in_year/26)
        when "monthly"
          daily_income = income_deduction.amount_in_cents / (working_days_in_year/12)
        when "quarterly"
          daily_income = income_deduction.amount_in_cents / (working_days_in_year/4)
        when "half_yearly"
          daily_income = income_deduction.amount_in_cents / (working_days_in_year/2)
        when "yearly"
          daily_income = income_deduction.amount_in_cents / (working_days_in_year)
      end

      income_deduction.start_date = Date.today.beginning_of_year if income_deduction.start_date.to_s.eql? "01-01-0001" or income_deduction.start_date.blank?

      income_deduction.end_date = Date.today.end_of_year if income_deduction.end_date.to_s.eql? "01-01-0001" or income_deduction.end_date.blank?

      years = (income_deduction.start_date.year..income_deduction.end_date.year)

      years.to_a.each do |year|


        actual_days_worked = compute_actual_days_worked(year, income_deduction.start_date, income_deduction.end_date)
        income_deduction_per_year[year] += actual_days_worked * daily_income

      end
    end

    income_deduction_per_year

  end

  # The person may have not worked the entire year. This method computed the actual days worked.
  def compute_actual_days_worked(year, start_date, end_date)

    working_days_in_year = Float(52*5)

    if Date.new(year, 1, 1) < start_date
      start_date_to_consider = start_date
    else
      start_date_to_consider = Date.new(year, 1, 1)
    end

    if Date.new(year, 1, 1).end_of_year < end_date
      end_date_to_consider = Date.new(year, 1, 1).end_of_year
    else
      end_date_to_consider = end_date
    end

    # we have to add one to include last day of work. We multiply by working_days_in_year/365 to remove weekends.
    ((end_date_to_consider - start_date_to_consider + 1).to_i * (working_days_in_year/365)).to_i #actual days worked in 'year'
  end

  def is_receiving_benefits_this_year?(alternate_benefit)

    alternate_benefit.start_date = Date.today.beginning_of_year if alternate_benefit.start_date.blank?

    alternate_benefit.end_date = Date.today.end_of_year if alternate_benefit.end_date.blank?

    (alternate_benefit.start_date.year..alternate_benefit.end_date.year).include? Date.today.year
  end



end
