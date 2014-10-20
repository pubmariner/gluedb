class DocumentValidator
  include ActiveModel::Validations

  XML_NS = {
    "cv" => "http://openhbx.org/api/terms/1.0"
  }

  validate :check_against_schema

  attr_reader :document, :schema

  def initialize(doc, sch)
    @schema = sch
    @document = doc
  end

  def check_against_schema
    doc_errors = @schema.validate(@document)
    doc_errors.each do |err|
      errors.add(:document, err.to_s)
    end
  end

end
