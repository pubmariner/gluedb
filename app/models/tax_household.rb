class TaxHousehold
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning
  include Mongoid::Paranoia
  include AASM

  # Unique identifier for this Household used for reporting enrollment and premium tax credits to IRS
  auto_increment :irs_group_id
  # field :irs_group_id, type: String

#  field :rel, as: :relationship, type: String
  field :e_pdc_id, type: String  # Eligibility system PDC foreign key


  field :primary_applicant_id, type: String

  field :magi_in_cents, type: Integer, default: 0  # Modified Adjusted Gross Income

  # Premium tax credit assistance eligibility.  
  # Available to household with income between 100% and 400% of the Federal Poverty Level (FPL)
  field :max_aptc_in_cents, type: Integer, default: 0

  # Cost-sharing reduction assistance eligibility for co-pays, etc.  
  # Available to households with income between 100-250% of FPL and enrolled in Silver plan.
  field :csr_percent, type: BigDecimal, default: 0.00   #values in DC: 0, .73, .87, .94

  field :eligibility_status_code, type: String
  field :eligibility_date, type: Date
  field :is_active, type: Boolean, default: true   # this Household active on the Exchange?

  validates_presence_of :eligibility_date, :max_aptc_in_cents, :csr_percent
  validate :csr_as_percent

  index({e_pdc_id: 1})
  index({irs_group_id: 1})
  index({eligibility_date: 1})

#  validates :rel, presence: true, inclusion: {in: %w( subscriber responsible_party spouse life_partner child ward )}

  embedded_in :application_group
  has_many :tax_household_members, class_name: "Person", inverse_of: :tax_household_member
  
  # embeds_one :total_income, inverse_of: :income

  # has_many :policies
  embeds_many :hbx_enrollments
  embeds_many :enrollment_exemptions
  embeds_many :eligibility_determinations

  embeds_many :comments
  accepts_nested_attributes_for :comments, reject_if: proc { |attribs| attribs['content'].blank? }, allow_destroy: true


  def total_incomes_by_year
    tax_household_members.inject({}) do |acc, per|
      p_incomes = per.assistance_eligibilities.inject({}) do |acc, ae|
        acc.merge(ae.total_incomes_by_year) { |k, ov, nv| ov + nv }
      end
      acc.merge(p_incomes) { |k, ov, nv| ov + nv }
    end
  end

  #TODO: return count for adult (>=21), chlid (<21) and total
  def size
    person.count 
  end

  def magi_in_dollars=(dollars)
    self.magi_in_cents = Rational(dollars) * Rational(100)
  end

  def magi_in_dollars
    (Rational(magi_in_cents) / Rational(100)).to_f if magi_in_cents
  end

  def max_aptc_in_dollars=(dollars)
    self.max_aptc_in_cents = Rational(dollars) * Rational(100)
  end

  def max_aptc_in_dollars
    (Rational(max_aptc_in_cents) / Rational(100)).to_f if max_aptc_in_cents
  end

  # Income sum of all tax filers in this Household for specified year
  def total_income(year)
  end

  def self.create_for_people(the_people)
    found = self.where({
      "person_ids" => {
        "$all" => the_people.map(&:id),
        "$size" => the_people.length
       }
    }).first
    return(nil) if found
    self.create!( :people => the_people )
  end

  def subscriber
    #TODO - correct when household has policy association
    people.detect do |person|
      person.members.detect do |member|
        member.enrollees.detect(&:subscriber?)
      end
    end
  end

  def head_of_household
    relationship = application_group.person_relationships.detect { |r| r.relationship_kind == "self" }
    Person.find_by_id(relationship.subject_person)
  end

private
  # Validate csr_percent value is in range 1..0
  def csr_as_percent
    errors.add(:csr_percent, "value must be between 0 and 1") unless (0 <= csr_percent && csr_percent <= 1)
  end

end
