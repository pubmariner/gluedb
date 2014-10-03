require 'rails_helper'

describe Deduction do
  describe "validate associations" do
    it { should be_embedded_in :assistance_eligibility }
  end

 let(:attributes) do
    {
      kind: :medicaid,
      income_type: 'wages_and_salaries',
      frequency: 'biweekly',
      start_date: DateTime.parse('2014-01-01'),
      end_date: DateTime.parse('2014-01-01'),
      submission_date: Date.today
    }
  end

  subject { Deduction.new(attributes) }


end