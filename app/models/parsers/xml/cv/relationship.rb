module Parsers::Xml::Cv
  class Relationship
    include NodeUtils

    RELATIONSHIP_MAP = {
      "is the aunt of" => "aunt_or_uncle",
      "is the child of" => "child",
      "is the cousin of" => "cousin",
      "is the domestic partner of" => "life_partner",
      "is the grandchild of" => "grandchild",
      "is the grandparent of" => "grandparent",
      "is the great grandparent of" => "great_grandparent",
      "is the guardian of" => "guardian",
      "is the nephew of" => "nephew_or_niece",
      "is the niece of" => "nephew_or_niece",
      "is the parent of" => "parent",
      "is the person cared for by" => "", #TODO
      "is the sibling of" => "sibling",
      "is the spouse of" => "spouse",
      "is the step child of" => "stepchild",
      "is the step parent of" => "stepparent",
      "is the step sibling of" => "sibling",
      "is the uncle of" => "aunt_or_uncle",
      "is unrelated to" => "unrelated"
    }

    def initialize(parser)
      @parser = parser
    end

    def subject
      first_text('./ns1:subject_individual')
    end

    def relationship
      RELATIONSHIP_MAP[first_text('./ns1:relationship_uri').downcase]
    end

    def object
      first_text('./ns1:object_individual')
    end

    def empty?
      (([subject, relationship, object].any?(&:blank?)) || (subject == object))
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
