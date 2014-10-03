require 'spec_helper'

describe Income do
  subject { Income.new(attributes) }

  let(:attributes) do
    {
      amount_in_cents: 1234,
      kind: 'dividend',
      frequency: 'biweekly',
      start_date: Date.today,
      end_date: Date.today,
      is_projected: true,
      submission_date: Date.today
    }
  end

  let(:other_income) { Income.new(attributes) }

  it 'can be matched with other incomes' do
    expect(other_income).to be_same_as subject
  end

  it 'can be made from an income request model' do
    request = {
      amount_in_dollars: 12.34,
      kind: 'wages_and_salaries',
      frequency: 'biweekly',
      start_date: Date.today,
      end_date: Date.today + 10,
      is_projected: true,
      submission_date: Date.today
    }
    expect(Income.from_income_request(request)).to be_same_as subject
  end

  it 'will sum all the incomes ' do
  end

end
