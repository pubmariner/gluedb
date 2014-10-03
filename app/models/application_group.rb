class ApplicationGroup
  include Mongoid::Document
  include Mongoid::Timestamps

  field :e_case_id, type: Integer  # Eligibility system foreign key
  field :is_active, type: Boolean, default: true   # ApplicationGroup active on the Exchange?

  field :primary_applicant_id, type: String     # Person who authorized auto-renewal eligibility check
  field :consent_applicant_id, type: String     # Person who authorized auto-renewal eligibility check
  field :consent_applicant_name, type: String
  field :coverage_renewal_year, type: Integer   # Authorize auto-renewal elibility check through this year (CCYY format)
  field :submission_date, type: Date

  field :notice_generated, type: Boolean, default: true
  has_many :policies


#  validates_inclusion_of :max_renewal_year, :in => 2013..2030, message: "must fall between 2013 and 2030"

  index({e_case_id:  1})
  index({is_active:  1})
  index({primary_applicant_id:  1})
  index({submission_date:  1})

  # TODO: An application can have only one kind of each Household active, except UQHP, where >1 may be active
  # Create validation for this rule 
  has_many :people

#  embeds_many :assistance_eligibilities
#  accepts_nested_attributes_for :assistance_eligibilities, reject_if: proc { |attribs| attribs['date_determined'].blank? }, allow_destroy: true

  embeds_many :households

  embeds_many :special_enrollment_periods, cascade_callbacks: true
  accepts_nested_attributes_for :special_enrollment_periods, reject_if: proc { |attribs| attribs['start_date'].blank? }, allow_destroy: true

  embeds_many :comments
  accepts_nested_attributes_for :comments, reject_if: proc { |attribs| attribs['content'].blank? }, allow_destroy: true

  scope :all_with_multiple_members, exists({ :'members.1' => true })

  # single SEP with latest end date from list of active SEPs
  def current_sep
    active_seps.max { |sep| sep.end_date }
  end

  # List of SEPs active for this Application Group today, or passed date
  def active_seps(day = Date.today)
    special_enrollment_periods.find_all { |sep| (sep.start_date..sep.end_date).include?(day) }
  end

  def self.default_search_order
    [
      ["name_last", 1],
      ["name_first", 1]
    ]
  end

  def people_relationship_map
    map = Hash.new
    people.each do |person|      
      map[person] = person_relationships.detect { |r| r.object_person == person.id }.relationship_kind
    end
    map
  end
  
end
