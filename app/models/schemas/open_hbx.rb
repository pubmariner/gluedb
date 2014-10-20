module Schemas
  class OpenHbx
    include Singleton

    attr_reader :schema

    def initialize
      file_path = File.expand_path(File.join(Rails.root, "public", "schemas", "vocabulary.xsd"))
      @schema = Nokogiri::XML::Schema(File.open(file_path))
    end

    def self.get
      self.instance.schema
    end

  end
end
