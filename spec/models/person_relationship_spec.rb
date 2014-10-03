require 'rails_helper'

describe PersonRelationship do
  subject { PersonRelationship.new(
    :subject_person => subject_person,
    :object_person => object_person
  )}

  let(:subject_person) { Person.new }
  let(:object_person) { Person.new }

  relationship_values = [
    "self",
    "spouse",
    "father",
    "mother",
    "grandfather",
    "grandmother",
    "grandson",
    "granddaughter",
    "uncle",
    "aunt",
    "nephew",
    "niece",
    "cousin",
    "adopted child",
    "foster child",
    "son-in-law",
    "daughter-in-law",
    "brother-in-law",
    "sister-in-law",
    "father-in-law",
    "mother-in-law",
    "brother",
    "sister",
    "ward",
    "stepparent",
    "stepson",
    "stepdaughter",
    "child",
    "sponsored dependent",
    "dependent of a minor dependent",
    "ex-spouse",
    "guardian",
    "court appointed guardian",
    "collateral dependent",
    "life partner",
    "annuitant",
    "trustee",
    "other relationship",
    "other relative"
  ]

  relationship_values.each do |rv|
    context("given a relationship_kind of #{rv}") do
      it "should be valid" do
        subject.relationship_kind = rv
        expect(subject).to be_valid
      end
    end
  end
end
