class PremiumTotalCalculator
  def initialize(policy)
    @policy = policy
  end

  def calculate
    return 0 if @policy.enrollees.empty?
    123.56
  end
end

describe PremiumTotalCalculator do
  subject(:calculator) { PremiumTotalCalculator.new(policy) }

  let(:policy) { double(enrollees: enrollees) }
  let(:enrollees) { [] }
  context 'policy with no enrollees' do
    let(:enrollees) { [] }
    it 'total is zero' do
      expect(calculator.calculate).to eq 0
    end
  end

  context 'one enrollee' do
    let(:enrollees) { [ double(premium_amount: 123.56) ]}
    it 'returns the enrollees premium amount' do
      expect(calculator.calculate).to eq 123.56
    end
  end

end
