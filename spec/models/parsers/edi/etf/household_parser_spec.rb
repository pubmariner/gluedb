require_relative File.join("..", "..", "..", "..", "spec_helper")

describe Parsers::Edi::Etf::HouseholdParser do
  include EdiFactory

  let(:the_first_member_id) { "the first member id" }
  let(:another_member_id) { "another member id" }

  let(:person1) { double("person_1") }
  let(:person2) { double("person_2") }
  let(:people) { [person1, person2] }

  let(:l834) {
    {
      "L2000s" => [
        {
          "REFs" => [
            member_id_ref_segment(the_first_member_id)
          ]
        },
        {
          "REFs" => [
            member_id_ref_segment(another_member_id)
          ]
        }
      ]
    }
  }

  subject { Parsers::Edi::Etf::HouseholdParser.new(l834)  }

  it "should have the first member" do
    expect(subject.member_ids).to include(the_first_member_id)
  end
  it "should have the other member" do
    expect(subject.member_ids).to include(another_member_id)
  end

  it "should tell the household to create itself when persisted" do
    expect(Person).to receive(:find_for_members).with([the_first_member_id, another_member_id]).and_return(people)
    expect(Household).to receive(:create_for_people).with(people)
    subject.persist!
  end

end
