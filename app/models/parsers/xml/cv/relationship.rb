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
=begin
is the aunt of
is the child of
is the cousin of
is the domestic partner of
is the grandchild of
is the grandparent of
is the great grandparent of
is the guardian of
is the nephew of
is the niece of
is the parent of
is the person cared for by
is the sibling of
is the spouse of
is the step child of
is the step parent of
is the step sibling of
is the uncle of
is unrelated to
=end

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
