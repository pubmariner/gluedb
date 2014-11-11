require 'spec_helper'

describe EnrollmentTransaction do
  subject(:enrollment_transaction) { build(:enrollment_transaction) }

  it { should have_index_for(ts_id: 1) }

  describe "validate associations" do
    it { should be_embedded_in :policy }
  end

  [
    :kind,
    :ts_id,
    :ts_control_number
  ].each do |attribute|
    it { should respond_to attribute }
  end


  let(:kind) { "19640229" }
  let(:name_last) { "LaName" }
  let(:name_first) { "Exampile" }
  let(:gender) { "male" }

  subject {
    EnrollmentTransaction.new(
      kind: name_first,
      ts_id: name_last,
      ts_control_number: dob
    )
  }

  it { should be_valid }

  it "should be valid with a blank ssn" do
    subject.ssn = ""
    subject.should be_valid
  end

  describe '#valid?' do
    let(:member) { Member.new(gender: 'male') }
    let(:person) { Person.new(name_first: 'Joe', name_last: 'Dirt') }
    before { person.members << member }

    context 'members hbx id equals the person authority member id' do
      before do
        person.authority_member_id = '666'
        member.hbx_member_id = '666'
      end
      it 'returns true' do
        expect(member.authority?).to eq true
      end
    end

    context 'members hbx id NOT equal to the person authority member id' do
      before do
        person.authority_member_id = '666'
        member.hbx_member_id = '7'
      end
      it 'returns true' do
        expect(member.authority?).to eq false
      end
    end
  end

end