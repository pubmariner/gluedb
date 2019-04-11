class FederalTransmission
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :created_at, type: DateTime
  field :report_type, type: String
  field :batch_id, type: String
  field :content_file, type: String
  field :record_sequence_number, type: String
  field :federal_policy_id, type: Moped::BSON::ObjectId

  embedded_in :policy
end