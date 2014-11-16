class HbxEnrollmentExemption
  include Mongoid::Document
  include Mongoid::Timestamps

  KINDS = %W[hardship health_care_ministry_member incarceration indian_tribe_member religious_conscience]

  embedded_in :application_group

  auto_increment :_id, seed: 9999
  field :kind, type: String
  field :certificate_number, type: String
  field :start_date, type: Date
  field :end_date, type: Date
  field :irs_group_id, type: Integer


  embeds_many :comments
  accepts_nested_attributes_for :comments, reject_if: proc { |attribs| attribs['content'].blank? }, allow_destroy: true

  validates :kind, 
  					presence: true,
  					allow_blank: false,
  					allow_nil:   false,
  					inclusion: {in: KINDS}


  def parent
    raise "undefined parent ApplicationGroup" unless application_group? 
    self.application_group
  end

  def irs_group=(irs_instance)
    return unless irs_instance.is_a? IrsGroup
    self.irs_group_id = irs_instance._id
  end


end
