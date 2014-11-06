module Protocols::Csv
  class CsvTransmission
    include Mongoid::Document
    include Mongoid::Timestamps

    field :batch_id, type: String
    field :file_name, type: String
    field :submitted_by, type: String

    index({:batch_id => 1, :file_name => 1})

    belongs_to :carrier, :index => true

    has_many :csv_transactions, :class_name => "Protocols::Csv::CsvTransaction"

    def self.find_or_create_transmission(data)
      transmission = self.where({
        :batch_id => data[:batch_id],
        :file_name => data[:file_name]        
      }).first
      return transmission if transmission
      self.create!(data)
    end
  end
end
