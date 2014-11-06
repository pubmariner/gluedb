class HbxEnrollment
  include Mongoid::Document
  include Mongoid::Timestamps

  ENROLLMENT_TYPE_LIST = %W[unassisted_qhp insurance_assisted_qhp employer_sponsored streamlined_medicaid emergency_medicaid hcr_chip]

  field :kind, type: String
  field :aasm_state, type: String

  field :allocated_aptc_in_cents, type: Integer
  field :csr_as_percent, type: Integer

  belongs_to :broker

  embeds_many :comments
  accepts_nested_attributes_for :comments, reject_if: proc { |attribs| attribs['content'].blank? }, allow_destroy: true

  validates :kind, 
  					presence: true,
  					allow_blank: false,
  					allow_nil:   false,
  					inclusion: {in: ENROLLMENT_TYPE_LIST}

end
