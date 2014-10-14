module Protocols::Csv
  class CsvTransmission
    include Mongoid::Document

    # TODO: Accept this in request
    field :batch_id, type: String
    # TODO: Accept this in request
    field :file_name, type: String
    # TODO: Accept this in request
    field :submitted_by, type: String

    belongs_to :carrier

    has_many :csv_transactions, :class_name => "Protocols::Csv::CsvTransaction"
  end
end
