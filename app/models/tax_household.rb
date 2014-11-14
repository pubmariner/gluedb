class TaxHousehold
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :application_group

  auto_increment :_id, seed: 9999

  # embedded belongs_to :irs_group association
  field :irs_group_id, type: Integer
  field :primary_applicant_id, type: Moped::BSON::ObjectId
  field :is_active, type: Boolean, default: true   # this Household active on the Exchange?
  
  # field :e_pdc_id, type: String  # Eligibility system PDC foreign key

  index({_id: 1})

  embeds_many :applicant_links
  embeds_many :comments
  accepts_nested_attributes_for :comments, reject_if: proc { |attribs| attribs['content'].blank? }, allow_destroy: true

  def parent
    self.application_group
  end

  def members
    parent.tax_household_members.where(:tax_household_id => id)
  end

  def irs_group=(irs_instance)
    return unless irs_instance.is_a? IrsGroup
    self.irs_group_id = irs_instance._id
  end

  def irs_groups
    parent.irs_groups.find(self.irs_group_id)
  end

  def primary_applicant=(person_instance)
    return unless person_instance.is_a? Person
    self.primary_applicant_id = person_instance._id
  end

  def primary_applicant
    Person.find(self.primary_applicant_id) unless self.primary_applicant_id.blank?
  end

  def total_incomes_by_year
    tax_household_members.inject({}) do |acc, per|
      p_incomes = per.assistance_eligibilities.inject({}) do |acc, ae|
        acc.merge(ae.total_incomes_by_year) { |k, ov, nv| ov + nv }
      end
      acc.merge(p_incomes) { |k, ov, nv| ov + nv }
    end
  end

  #TODO: return count for adult (>=21), child (<21) and total
  def size
    members.size 
  end

  def magi_in_dollars=(dollars)
    self.magi_in_cents = Rational(dollars) * Rational(100)
  end

  def magi_in_dollars
    (Rational(magi_in_cents) / Rational(100)).to_f if magi_in_cents
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

end
