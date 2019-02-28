class CarrierProfile
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :carrier

  field :fein, type: String
  field :profile_name, type: String
  field :requires_reinstate_for_earlier_termination, type: Boolean, default: false
end
