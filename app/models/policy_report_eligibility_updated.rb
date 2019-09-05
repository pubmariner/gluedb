class PolicyReportEligibilityUpdated
  include Mongoid::Document
  include Mongoid::Timestamps

  field :eg_id, type: String

  validates_uniqueness_of :eg_id

end