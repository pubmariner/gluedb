class HbxEnrollment
  include Mongoid::Document
  include Mongoid::Timestamps
  include AASM

  KINDS = %W[unassisted_qhp insurance_assisted_qhp employer_sponsored streamlined_medicaid emergency_medicaid hcr_chip]

  embedded_in :application_group

  auto_increment :_id, seed: 9999

  # embedded belongs_to IrsGroup association
  field :policy_id, type: Moped::BSON::ObjectId
  field :irs_group_id, type: Moped::BSON::ObjectId
  field :kind, type: String
  field :primary_applicant_id, type: Moped::BSON::ObjectId

  field :allocated_aptc_in_cents, type: Integer
  field :csr_percent_as_integer, type: Integer
  field :aasm_state, type: String

  belongs_to :broker

  # Polymorphic?

    # field :policy_id, type: Moped::BSON::ObjectId
    # field :eligibility_determination_id, type: Moped::BSON::ObjectId
    # field :applied_aptc_in_cents, type: Integer
    # field :elected_aptc_in_cents, type: Integer
    # field :allocated_aptc_in_cents, type: Integer
    # field :csr_percent, type: Float


  embeds_many :applicant_links
  embeds_many :comments
  accepts_nested_attributes_for :comments, reject_if: proc { |attribs| attribs['content'].blank? }, allow_destroy: true

  validates :kind, 
  					presence: true,
  					allow_blank: false,
  					allow_nil:   false,
  					inclusion: {in: KINDS}


  def parent
    self.application_group
  end

  def policy
    Policy.find(self.policy_id) unless self.policy_id.blank?
  end

  def policy=(policy_instance)
    return unless policy_instance.is_a? Policy
    self.policy_id = policy_instance._id
    parent.enrollment_policies << policy_instance
  end

  def irs_group=(irs_instance)
    return unless irs_instance.is_a? IrsGroup
    self.irs_group_id = irs_instance._id
  end

  def irs_group
    parent.irs_groups.find(self.irs_group_id)
  end

  def primary_applicant=(person_instance)
    return unless person_instance.is_a? Person
    self.primary_applicant_id = person_instance._id
  end

  def primary_applicant
    Person.find(self.primary_applicant_id) unless self.primary_applicant_id.blank?
  end

  def allocated_aptc_in_dollars=(dollars)
    self.allocated_aptc_in_cents = Rational(dollars) * Rational(100)
  end

  def allocated_aptc_in_dollars
    (Rational(allocated_aptc_in_cents) / Rational(100)).to_f if allocated_aptc_in_cents
  end


  aasm do
    state :enrollment_closed, initial: true
  end

private
  # Validate csr_percent value is in range 1..0
  def csr_as_percent
    errors.add(:csr_percent, "value must be between 0 and 1") unless (0 <= csr_percent && csr_percent <= 1)
  end


end
