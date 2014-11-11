class EnrollmentExemption
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning
  include Mongoid::Paranoia

  # TYPES = %w[]
  KINDS = %W[hardship health_care_ministry_member incarceration indian_tribe_member religious_conscience]

  auto_increment :_id
  field :certificate_number, type: String
  field :kind, type: String
  field :start_date, type: Date
  field :end_date, type: Date

  embedded_in :application_group

  embeds_many :comments
  accepts_nested_attributes_for :comments, reject_if: proc { |attribs| attribs['content'].blank? }, allow_destroy: true

  validates :kind, 
  					presence: true,
  					allow_blank: false,
  					allow_nil:   false,
  					inclusion: {in: KINDS}

end
