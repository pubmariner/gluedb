require "rails_helper"

def expect_address_to_change(person, request)
  expect(person.addresses.first.address_type).to eq request.to_hash[:type]
  expect(person.addresses.first.address_1).to eq request.to_hash[:address1]
  expect(person.addresses.first.address_2).to eq request.to_hash[:address2]
  expect(person.addresses.first.city).to eq request.to_hash[:city]
  expect(person.addresses.first.state).to eq request.to_hash[:state]
  expect(person.addresses.first.zip).to eq request.to_hash[:zip]
end

describe ChangeMemberAddress do
  subject(:change_address) { ChangeMemberAddress.new(transmitter, person_repo, address_repo, eligible_policy_factory) }
  let(:listener) { double(:fail => nil, :success => nil) }
  let(:transmitter) { double(execute: nil) }
  let(:person_repo) { double(find_by_id: person) }
  let(:address_repo) { Address }
  let(:person) { Person.new }
  let(:eligible_policy_factory) { double(:for_person => eligible_policies) }
  let(:eligible_policies) { double(:empty? => false, too_many_health_policies?: false, too_many_dental_policies?: false) }
  
  let(:policy) { double(id: '12345', plan: plan, enrollees: [target_enrollee], active_enrollees: [target_enrollee], :has_responsible_person? => false, currently_active?: true, coverage_type: 'health') }
  let(:plan) { double(coverage_type: coverage_type) }
  let(:coverage_type) { 'health'}

  let(:target_enrollee) { double(m_id: '1234', person: person, coverage_status: 'active', subscriber?: true) } 

  let(:request) do
    {
      :person_id => '1',
      :type => 'home',
      :address1 => '4321 cool drive',
      :address2 => '#999',
      :city => 'Seattle',
      :state => 'GA',
      :zip => '12345',
      :current_user => 'me@example.com',
    }
  end

  let(:address) { Address.new(address_fields) }

  let(:address_fields) do
    {
      address_type: 'home', 
      address_1: '1234 awesome street', 
      address_2: '#123', 
      city: 'Atlanta', 
      state: 'GA', 
      zip: '12345'
    }
  end

  let(:transmit_request) do
    {
      policy_id: policy.id,
      operation: 'change',
      reason: 'change_of_location',
      affected_enrollee_ids: [target_enrollee.m_id],
      include_enrollee_ids: [target_enrollee.m_id],
      current_user: 'me@example.com' 
    }
  end

  before do
    allow(policy).to receive(:subscriber).and_return(target_enrollee)
    allow(eligible_policies).to receive(:each).and_yield(policy)
    allow(eligible_policies).to receive(:each_affected_group).and_yield(policy, [target_enrollee], [target_enrollee])
    person.addresses << address
    person.save
  end

  it 'finds the person by id' do
    expect(person_repo).to receive(:find_by_id).with(request[:person_id])
    expect(listener).to receive(:success)
    change_address.execute(request, listener)
  end

  it 'changes address of person' do
    expect(listener).to receive(:success)
    change_address.execute(request, listener)
    expect_address_to_change(person, request)
  end

  it 'transmits the changes' do
    expect(transmitter).to receive(:execute).with(transmit_request)
    expect(listener).to receive(:success)
    change_address.execute(request, listener)
  end

  context 'when there are active enrollees that share original address' do
    let(:other_person) { Person.new }
    let(:other_enrollee) { double(m_id: '6666', person: other_person, coverage_status: 'active') }
    let(:matching_address) { Address.new(address_fields) }

    before do
      allow(eligible_policies).to receive(:each_affected_group).and_yield(policy, [target_enrollee, other_enrollee], [target_enrollee, other_enrollee])
      other_person.addresses << matching_address
      person.save
    end

    context 'person is a subscriber' do
      it 'also changes their address' do
        expect(listener).to receive(:success)
        change_address.execute(request, listener)
        expect_address_to_change(other_person, request)
      end
    end

    context 'person is NOT a subscriber' do
      before do 
        allow(target_enrollee).to receive(:subscriber?).and_return(false)
        allow(eligible_policies).to receive(:each_affected_group).and_yield(policy, [target_enrollee], [target_enrollee, other_enrollee])
      end
      it 'does not change their address' do
        expect(listener).to receive(:success)
        change_address.execute(request, listener)
        expect(other_person.addresses.first.address_type).to eq matching_address.address_type
        expect(other_person.addresses.first.address_1).to eq matching_address.address_1
        expect(other_person.addresses.first.address_2).to eq matching_address.address_2
        expect(other_person.addresses.first.city).to eq matching_address.city
        expect(other_person.addresses.first.state).to eq matching_address.state
        expect(other_person.addresses.first.zip).to eq matching_address.zip
      end
    end
  end

  context 'when there is another active enrollee with different address' do
    let(:other_person) { Person.new }
    let(:different_address) { Address.new(address_type: 'home', 
      address_1: '1234 somethingelse', 
      address_2: '#654', 
      city: 'Atlanta', 
      state: 'GA', 
      zip: '12345') }

    before do
      other_person.addresses << different_address
      person.save
    end

    it 'does not change their address' do
      expect(listener).to receive(:success)
      change_address.execute(request, listener)
      expect(other_person.addresses.first.address_type).to eq different_address.address_type
      expect(other_person.addresses.first.address_1).to eq different_address.address_1
      expect(other_person.addresses.first.address_2).to eq different_address.address_2
      expect(other_person.addresses.first.city).to eq different_address.city
      expect(other_person.addresses.first.state).to eq different_address.state
      expect(other_person.addresses.first.zip).to eq different_address.zip
    end
  end

  context 'when person doesnt exist' do 
    let(:person_repo) { double(find_by_id: nil) }
    it 'notifies listener of no such member' do
      expect(listener).to receive(:no_such_person).with({:person_id => request[:person_id]})
      expect(listener).to receive(:fail)
      change_address.execute(request, listener)
    end
  end

  context "when the member has more than one active health policy" do
    let(:coverage_type) { 'health' }
    let(:eligible_policies) { double(:empty? => false, too_many_health_policies?: true, too_many_dental_policies?: false) }
    let(:other_policy) { double(plan: double(coverage_type: coverage_type), enrollees: [other_enrollee], :has_responsible_person? => false) } 
    let(:other_enrollee) { double(person: person) }


    it 'notifies the listener of too many health policies' do 
      expect(listener).to receive(:too_many_health_policies).with({:member_id => request[:member_id]})
      expect(listener).to receive(:fail)
      change_address.execute(request, listener)
    end
  end

  context "when the member has more than one active dental policy" do
    let(:coverage_type) { 'dental' }
    let(:eligible_policies) { double(:empty? => false, too_many_health_policies?: false, too_many_dental_policies?: true) }

    it 'notifies the listener of too many dental policies' do 
      expect(listener).to receive(:too_many_dental_policies).with({:member_id => request[:member_id]})
      expect(listener).to receive(:fail)
      change_address.execute(request, listener)
    end
  end

  context "when given an invalid address" do
    let(:address_error_details) { {:zip => ["can't be blank"]} }
    let(:invalid_address) { double(:valid? => false, :errors => address_error_details) }
    let(:address_repo) { double(:new => invalid_address) }

    it 'notifies the listener that there is an invalid address' do
      expect(listener).to receive(:invalid_address).with(address_error_details)
      expect(listener).to receive(:fail)
      change_address.execute(request, listener)
    end
  end

  context "when the member has no active policies" do
    let(:eligible_policies) { double(:empty? => true, too_many_health_policies?: false, too_many_dental_policies?: false) }
    before do 
      allow(eligible_policies).to receive(:each_affected_group).and_return(nil)
    end

    it 'changes the address' do
      change_address.execute(request, listener)
      expect_address_to_change(person, request)
    end

    it 'does not transmit' do
      expect(transmitter).not_to receive(:execute)
      change_address.execute(request, listener)
    end

    it 'succeeds' do
      expect(listener).to receive(:success)
      change_address.execute(request, listener)
    end
   

  end

  context "when member has one active dental and one active health policy" do
    let(:coverage_type) { 'health' }
    let(:other_policy) { double(id: '999', plan: double(coverage_type: 'dental'), enrollees: [other_enrollee], active_enrollees: [other_enrollee], :has_responsible_person? => false) }
    let(:other_enrollee) { double(m_id: '999', person: person) }
    
    let(:other_transmit_request) do
      {
        policy_id: other_policy.id,
        operation: 'change',
        reason: 'change_of_location',
        affected_enrollee_ids: [other_enrollee.m_id],
        include_enrollee_ids: [other_enrollee.m_id],
        current_user: 'me@example.com' 
      }
    end
    before {
      allow(eligible_policies).to receive(:each_affected_group).and_yield(
        policy, [target_enrollee], [target_enrollee]).and_yield(
          other_policy, [other_enrollee], [other_enrollee]
        )
    }
    
    it 'should transmit the changes on both policies' do
      expect(transmitter).to receive(:execute).with(transmit_request)
      expect(transmitter).to receive(:execute).with(other_transmit_request)
      expect(listener).to receive(:success)

      change_address.execute(request, listener)
    end

    context "when the dental policy has a responsible party" do
      let(:other_policy) { double(id: '999', plan: double(coverage_type: 'dental'), enrollees: [other_enrollee], active_enrollees: [other_enrollee], :has_responsible_person? => true) }
      before {
        allow(eligible_policies).to receive(:each).and_yield(policy).and_yield(other_policy)
      }

      it 'notifies the listener that a policy has a responsible party' do
        expect(listener).to receive(:responsible_party_on_policy).with({:policy_id => '999'})
        expect(listener).to receive(:fail)
        change_address.execute(request, listener)
      end
    end
  end
end
