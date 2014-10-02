=begin
require 'spec_helper'

describe AddIncome do
  subject { AddIncome.new(person_repo, income_factory) }

  let(:person_repo) { double(find_by_id: person) }
  let(:income_factory) { Income }
  let(:income) { Income.from_income_request(request[:incomes].first) }
  let(:person) { Person.new(name_first: 'Joe', name_last: 'Dirt') }
  let(:request) do
    {
      person_id: person.id,
      incomes: [
        {
          amount: 12.34,
          income_type: 'wages_and_salaries',
          frequency: 'biweekly',
          start_date: Date.today,
          end_date: Date.today,
          evidence_flag: false,
          reported_date: Date.today,
          reported_by: 'someone'
        }
      ],
      current_user: current_user
    }
  end

  let(:current_user) { 'me@example.com' }

  it 'finds the person' do
    expect(person_repo).to receive(:find_by_id).with(request[:person_id])
    subject.execute(request)
  end

  it 'creates a new income' do
    request[:incomes].each do |income|
      expect(income_factory).to receive(:from_income_request).with(income)
    end

    subject.execute(request)
  end

  it "added incomes to person" do
    subject.execute(request)
    first_income = person.incomes.first
    requested_income = Income.from_income_request(request[:incomes].first)

    expect(first_income).to be_same_as requested_income
  end

  context 'when an income is added twice' do
    before do
      2.times { subject.execute(request) }
    end   
    it 'is only recorded once' do
      expect(person.incomes.count).to eq 1
    end
  end

  it 'saves the person' do
    expect(person).to receive(:save!)
    subject.execute(request)
  end

  it 'records the user that made the change' do
    subject.execute(request)
    expect(person.updated_by).to eq current_user
  end
=end
