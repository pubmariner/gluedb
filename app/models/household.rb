class Household
  include Mongoid::Document
  include Mongoid::Timestamps
  #include Mongoid::Versioning
  include Mongoid::Paranoia

  KIND = %W(uqhp, aqhp, shop, medicaid)

#  field :rel, as: :relationship, type: String
  field :consent_applicant, type: Integer
  field :active, type: Boolean, default: true   # Household active on the Exchange?
  field :irs_group_id, type: String

  field :e_product_id, type: String  # Eligibility system PDC foreign key
  field :primary_applicant_id, type: String
  field :kind, type: String

  index({irs_group_id:  1})

#  validates :rel, presence: true, inclusion: {in: %w( subscriber responsible_party spouse life_partner child ward )}

  belongs_to :application_group
  has_many :policies, autosave: true
  embeds_many :assistance_applicants

  embeds_many :eligibilities
  accepts_nested_attributes_for :eligibilities, reject_if: proc { |attribs| attribs['date_determined'].blank? }, allow_destroy: true

  embeds_many :comments
  accepts_nested_attributes_for :comments, reject_if: proc { |attribs| attribs['content'].blank? }, allow_destroy: true

  # Number of people in this household for elibility determination purposes
  def size
    applicant.count #TODO: may be filtered by tax filer type??
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

  def current_eligibility
    eligibilities.max_by { |e| e.date_determined }
  end

  # Value from latest eligibility determination
  def max_aptc
    current_eligibility.max_aptc
  end

  # Value from latest eligibility determination
  def csr_percent
    current_eligibility.csr_percent
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
