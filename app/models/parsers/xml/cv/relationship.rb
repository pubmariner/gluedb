module Parsers::Xml::Cv
  class Relationship
    include NodeUtils
    def initialize(parser)
      @parser = parser
    end

    def subject
      first_text('./ns1:subject_individual')
    end

    def relationship_urn
      first_text('./ns1:relationship_uri')
    end

    def relationship
      relationship_urn.split('#').last
    end

    def object
      first_text('./ns1:object_individual')
    end

    def empty?
      [subject, relationship_urn, object].any?(&:blank?)
    end

    def to_request
      {
        :subject_person => subject,
        :object_person => object,
        :relationship_kind => relationship
      }
    end
  end
end
