require 'spec_helper'

describe Income do
  subject { Income.new(attributes) }

  let(:attributes) do
    {
      amount_in_cents: 1234,
      income_type: 'wages_and_salaries',
      frequency: 'biweekly',
      start_date: Date.today,
      end_date: Date.today,
      evidence_flag: Date.today,
      reported_date: Date.today,
      reported_by: 'Someone'
    }
  end

  let(:other_income) { Income.new(attributes) }

  it 'can be matched with other incomes' do
    expect(other_income).to be_same_as subject
  end

  it 'can be made from an income request model' do
    request = {
      amount: 12.34,
      income_type: 'wages_and_salaries',
      frequency: 'biweekly',
      start_date: Date.today,
      end_date: Date.today,
      evidence_flag: false,
      reported_date: Date.today,
      reported_by: 'someone'
    }
    expect(Income.from_income_request(request)).to be_same_as subject
  end
end
