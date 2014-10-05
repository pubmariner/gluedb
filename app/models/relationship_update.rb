class RelationshipUpdate
  attr_accessor :subject_person_id, :relationship_kind, :object_person_id
  KEYS = [:subject_person_id, :relationship_kind, :object_person_id]

  def initialize(data = {})
    data.each_pair do |k, v|
      if KEYS.include?(k.to_sym)
        self.send("#{k}=", v)
      end
    end
  end

  def subject_person
    @subject_person ||= Person.find_by_id(@subject_person_id)
  end

  def object_person
    @object_person ||= Person.find_by_id(@object_person_id)
  end

  def save!
    new_rel = PersonRelationship.new({
      :subject_person => subject_person,
      :object_person => object_person,
      :relationship_kind => relationship_kind
    })
    old_rels = subject_person.person_relationships.select do |rel|
      rel.object_person_id == object_person.id
    end
    old_rels.each do |old_rel|
      subject_person.person_relationships.delete(old_rel)
    end

    subject_person.person_relationships << new_rel
    subject_person.save!

    inverse = new_rel.inverse
    if(inverse)
      old_rels = object_person.person_relationships.select do |rel|
        rel.object_person_id == subject_person.id
      end
      old_rels.each do |old_rel|
        subject_person.person_relationships.delete(old_rel)
      end
      object_person.person_relationships << inverse
      object_person.save!
    end
  end
end
