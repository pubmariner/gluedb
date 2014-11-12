class EdiOpsTransaction
  include Mongoid::Document
  include Mongoid::Timestamps

  field :qualifying_reason_uri, type: String
  field :enrollment_group_uri, type: String
  field :submitted_timestamp, type: DateTime
  field :event_key, type: String
  field :event_name, type: String
  field :errors, type: Hash
  field :valid, type: Boolean, default: true

  field :status, type: String
end
