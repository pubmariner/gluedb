require 'rails_helper'

describe QualificationUpdate do

  let(:member) { double }
  let(:member_id) { "memberid" }
  let(:updated_attributes) {
   {
      :is_incarcerated => false,
      :is_state_resident => true,
      :citizen_status => "not_lawfully_present_in_us",
      :e_person_id => "123",
      :e_concern_role_id => "4321",
      :aceds_id => "9999"
   }
  }
  subject { QualificationUpdate.new(updated_attributes.merge({:member_id => member_id})) }

  before(:each) do
    allow(Member).to receive(:find_for_member_id).with(member_id).and_return(member)
  end

  it "should be able to find the member" do
    expect(subject.member).to eq member
  end

  it "should update the attributes for :citizen_status, :is_state_resident, and :is_incarcerated" do
    expect(member).to receive(:update_attributes!).with(updated_attributes)
    subject.save!
  end
end
