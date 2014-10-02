=begin
require 'spec_helper'

describe AddPerson do
  subject(:add_person) { AddPerson.new() }
  let(:application_group) { ApplicationGroup.new }
  let(:requested_relationship) { 'self' }
  let(:person) { create(:person, application_group_id: application_group.id) }

  before { application_group.save }

  it 'saves person to the database' do 
    expect { add_person.execute(person, requested_relationship) }.to change{ Person.count }.by(1)
  end

  it 'associates to an application group' do
    add_person.execute(person, requested_relationship)
    expect(application_group.people).to include Person.last
  end

  describe 'relationship assignment' do
    context 'representative(self) in group' do
      let(:requested_relationship) { 'spouse' }
      let(:assigned_relationship) { 'self' }

      it 'creates a relationship with itself' do
        add_person.execute(person, requested_relationship)

        application_group.reload

        added_person = Person.last
        relationship = application_group.person_relationships.first
        expect(relationship.subject_person).to eq added_person.id
        expect(relationship.relationship_kind).to eq assigned_relationship
        expect(relationship.object_person).to eq added_person.id
      end 

      it 'associates to an application group' do
        add_person.execute(person, requested_relationship)
        application_group.reload
        added_person = Person.last
        expect(application_group.people).to include added_person
      end
    end

    context 'no representative(self) in group' do
      let(:representative) { create(:person, application_group_id: application_group.id) }
      let(:requested_relationship) { 'spouse' }

      before { add_person.execute(representative, 'self' ) }

      it 'creates a relationship to the person marked as self' do
        add_person.execute(person, requested_relationship)

        application_group.reload
        added_person = Person.last

        relationship = application_group.person_relationships.last
        expect(relationship.subject_person).to eq Person.first.id
        expect(relationship.relationship_kind).to eq requested_relationship
        expect(relationship.object_person).to eq added_person.id
      end
    end
  end
end
=end
