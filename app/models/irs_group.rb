class IrsGroup
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning
  include Mongoid::Paranoia

  # Unique identifier for this Household used for reporting enrollment and premium tax credits to IRS
  auto_increment :_id

  embedded_in :application_group

  has_many :tax_households
  has_many :hbx_enrollments

  embeds_many :comments
  accepts_nested_attributes_for :comments, reject_if: proc { |attribs| attribs['content'].blank? }, allow_destroy: true


end
