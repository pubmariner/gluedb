require 'rails_helper'

describe ChangeEffectiveDate do
  subject(:change_effective_date) { ChangeEffectiveDate.new(transmitter, policy_repo) }
  let(:policy_repo) { double(where: double(first: policy)) }
  let(:policy) { double(id: '1234', enrollees: enrollees, save!: true, subscriber: subscriber, plan: plan, market: market, employer: employer, employer_contribution: 1.00, total_premium_amount: BigDecimal.new("100.0"), 'total_premium_amount=' => nil, 'employer_contribution=' => nil, 'total_responsible_amount=' => nil)}
  let(:plan) { double(rate: looked_up_premium )}
  let(:looked_up_premium) { double(amount: 123) }
  let(:market) { 'individual' }
  let(:employer) { nil }
  let(:request) do
    {
      policy_id: '1234',
      effective_date: Date.today.next_month.strftime("%Y%m%d"),
      current_user: current_user,
    }
  end

  let(:enrollees) { [ subscriber, other_enrollee ] }
  let(:other_enrollee) do
    Enrollee.new(
      coverage_start: Date.today, 
      m_id: "4231"
    )
  end
  let(:subscriber) do
    Enrollee.new(
      coverage_start: Date.today, 
      m_id: "5324", 
      rel_code: "self"
    )
  end
  let(:listener) { double(success: nil) }
  let(:transmitter) { double(execute: nil ) }
  let(:transmit_request) do
    {
      policy_id: policy.id,
      operation: 'change',
      reason: 'benefit_selection',
      affected_enrollee_ids: affected_enrollee_ids,
      include_enrollee_ids: affected_enrollee_ids,
      current_user: current_user 
    }
  end
  let(:affected_enrollee_ids) { [subscriber.m_id, other_enrollee.m_id] }

  let(:current_user) { 'me@example.com' }

  before do
    enrollees.each do |enrollee|
      allow(enrollee).to receive(:member).and_return(double(dob: Date.new(1980,02,01)))
    end
  end

  it 'finds the policy' do
    expect(policy_repo).to receive(:where).with({"_id" => request[:policy_id]})
    subject.execute(request, listener)
  end

  it 'changes all enrollees' do
    expect(policy).to receive(:save!)

    subject.execute(request, listener)
    
    enrollees.each do |enrollee|
      expect(enrollee.coverage_start).to eq Date.parse(request[:effective_date])
    end
  end

  it 'notifies listener' do
    expect(listener).to receive(:success)
    subject.execute(request, listener)
  end

  it 'transmits the changes' do
    expect(transmitter).to receive(:execute).with(transmit_request)
    subject.execute(request, listener)
  end

  context 'when policy is for individual market' do 
    let(:market) { 'individual' }
    it "updates enrollees' premium based on the new effective_date" do
      enrollees.each do |enrollee|
        new_effective_date = Date.parse(request[:effective_date])
        expect(policy.plan).to receive(:rate).with(new_effective_date, new_effective_date, enrollee.member.dob)
      end

      subject.execute(request, listener)
        
      enrollees.each do |enrollee|
        expect(enrollee.pre_amt).to eq(looked_up_premium.amount)
      end
    end
  end

  context 'when policy is for shop market' do
    let(:market) { 'shop' }
    let(:employer) { double(plan_year_start: Date.today.prev_year.prev_week)}

    it "updates enrollees' premium based on the new effective_date and employer plan year start" do
      enrollees.each do |enrollee|
        new_effective_date = Date.parse(request[:effective_date])
        expect(policy.plan).to receive(:rate).with(employer.plan_year_start, new_effective_date, enrollee.member.dob)
      end

      subject.execute(request, listener)
        
      enrollees.each do |enrollee|
        expect(enrollee.pre_amt).to eq(looked_up_premium.amount)
      end
    end

  end


  context "when policy doesn't exist" do
    let(:policy_repo) { double(where: double(first: nil)) }
    let(:listener) { double(no_such_policy: nil, fail: nil) }

    it 'notifies the listener' do
      expect(listener).to receive(:no_such_policy).with(policy_id: request[:policy_id])
      expect(listener).to receive(:fail)
      subject.execute(request, listener)
    end

    it "doesn't save the policy" do
      expect(policy).not_to receive(:save!)
      subject.execute(request, listener)
    end
  end

  context 'when subscriber is canceled' do
    let(:listener) { double(policy_inactive: nil, fail: nil)}
    let(:subscriber) { Enrollee.new(coverage_start: Date.today, coverage_end: Date.today) }
    
    it 'notifies the listener' do
      expect(listener).to receive(:policy_inactive).with(policy_id: request[:policy_id])
      expect(listener).to receive(:fail)
      subject.execute(request, listener)
    end
    it "doesn't save the policy" do
      expect(policy).not_to receive(:save!)
      subject.execute(request, listener)
    end
  end
  
  context 'when subscriber is terminated' do
    let(:listener) { double(policy_inactive: nil, fail: nil)}
    let(:subscriber) { Enrollee.new(coverage_start: Date.today, coverage_end: Date.today.next_month) }

    it 'notifies the listener' do
      expect(listener).to receive(:policy_inactive).with(policy_id: request[:policy_id])
      expect(listener).to receive(:fail)
      subject.execute(request, listener)
    end
    it "doesn't save the policy" do
      expect(policy).not_to receive(:save!)
      subject.execute(request, listener)
    end
  end

  context 'when subscriber already has requested effective date' do
    let(:listener) { double(no_changes_needed: nil, fail: nil)}
    let(:subscriber) { Enrollee.new(coverage_start: Date.parse(request[:effective_date])) }

    it 'notifies the listener' do
      expect(listener).to receive(:no_changes_needed).with(policy_id: request[:policy_id])
      expect(listener).to receive(:fail)
      subject.execute(request, listener)
    end

    it "doesn't save the policy" do
      expect(policy).not_to receive(:save!)
      subject.execute(request, listener)
    end
  end

  context "when the other enrollee is cancelled" do
    let(:other_enrollee) { Enrollee.new(coverage_start: Date.today, coverage_end: Date.today, m_id: "4231") }

    let(:affected_enrollee_ids) { [subscriber.m_id] }
    it 'changes only the subscriber' do

      expect(policy).to receive(:save!)

      subject.execute(request, listener)

      expect(subscriber.coverage_start).to eq Date.parse(request[:effective_date])
      expect(other_enrollee.coverage_start).not_to eq Date.parse(request[:effective_date])
    end

    it 'notifies listener' do
      expect(listener).to receive(:success)
      subject.execute(request, listener)
    end

    it 'transmits the changes' do
      expect(transmitter).to receive(:execute).with(transmit_request)
      subject.execute(request, listener)
    end
  end

  context "when the other enrollee is terminated" do
    let(:other_enrollee) { Enrollee.new(coverage_start: Date.today, coverage_end: Date.today.next_month, m_id: "4231") }
    let(:listener) { double(ambiguous_terminations: nil, fail: nil) }
    it 'notifies the listener' do
      expect(listener).to receive(:ambiguous_terminations).with({:policy_id => request[:policy_id], :member_ids => [other_enrollee.m_id]})
      expect(listener).to receive(:fail)
      subject.execute(request, listener)
    end

    it "doesn't save the policy" do
      expect(policy).not_to receive(:save!)
      subject.execute(request, listener)
    end
  end

  context "when the other enrollee has a different coverage_start" do
    let(:other_enrollee) { Enrollee.new(coverage_start: Date.today.next_month, m_id: "4231") }
    let(:listener) { double(start_date_mismatch: nil, fail: nil) }

    it 'notifies the listener' do
      expect(listener).to receive(:start_date_mismatch).with({:policy_id => request[:policy_id], :coverage_start => [subscriber.coverage_start, other_enrollee.coverage_start]})
      expect(listener).to receive(:fail)
      subject.execute(request, listener)
    end

    it "doesn't save the policy" do
      expect(policy).not_to receive(:save!)
      subject.execute(request, listener)
    end
  end
end
