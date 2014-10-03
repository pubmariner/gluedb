require 'rails_helper'

describe RelationshipUpdate do
  let(:person) { Person.new }
  let(:other_person) { Person.new }
  let(:new_relationship) {
    PersonRelationship.new(new_relationship_args)
  }
  let(:subject_id) { "abcdefg" }
  let(:other_person_id) { "fgabcde" }
  let(:relationship_kind) { "mother" }
  let(:new_relationship_args) {
    {
      :subject_person => person,
      :object_person => other_person,
      :relationship_kind => relationship_kind
    }
  }

  let(:subject) {
    RelationshipUpdate.new(
      :subject_person_id => subject_id,
      :object_person_id => other_person_id,
      :relationship_kind => relationship_kind
    )
  }

  before(:each) do
    allow(person).to receive(:save!)
    allow(PersonRelationship).to receive(:new).with(new_relationship_args).and_return(new_relationship)
    allow(Person).to receive(:find_by_id).with(subject_id).and_return(person)
    allow(Person).to receive(:find_by_id).with(other_person_id).and_return(other_person)
  end

  it "should have the correct subject_person" do
    expect(subject.subject_person).to eq person
  end

  it "should have the correct object_person" do
    expect(subject.object_person).to eq other_person
  end

  it "should have the correct relationship_kind" do
    expect(subject.relationship_kind).to eq relationship_kind
  end

  it "should create the new relationship on the subject person" do
    subject.save
    expect(person.person_relationships).to include(new_relationship)
  end

  context "when the subscriber already has a relationship with somebody else" do
    let(:person) { Person.new(:person_relationships => [old_relationship]) }
    let(:old_relationship) { PersonRelationship.new({:object_person => third_person}) }
    let(:third_person) { Person.new }
    it "should leave that relationship alone" do
      subject.save
      expect(person.person_relationships).to include(old_relationship)
      expect(person.person_relationships).to include(new_relationship)
    end
  end

  context "when those people already have a different, defined relationship" do
    let(:person) { Person.new(:person_relationships => [old_relationship]) }
    let(:old_relationship) { PersonRelationship.new({:object_person => other_person}) }

    it "should replace the old relationship" do
      subject.save
      expect(person.person_relationships).not_to include(old_relationship)
      expect(person.person_relationships).to include(new_relationship)
    end
  end
end
