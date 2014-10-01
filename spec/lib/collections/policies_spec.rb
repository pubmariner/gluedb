require 'spec_helper'

describe Collections::Policies do
  subject { Collections::Policies.new(policies) }
  let(:policies) { [health_policy, dental_policy] }
  let(:health_policy) { double(coverage_type: 'health') }
  let(:dental_policy) { double(coverage_type: 'dental') }

  describe '#covering_health' do
    it 'returns all health policies' do 
      expect(subject.covering_health.to_a).to include(health_policy)
    end
  end

  describe '#covering_dental' do
    it 'returns all dental policies' do
      expect(subject.covering_dental.to_a).to include(dental_policy)
    end
  end

  describe '#currently_active' do
    let(:policies) { [active_policy] }
    let(:active_policy) { double(currently_active?: true) }

    it 'returns policies that are currently active' do
      expect(subject.currently_active).to include(active_policy)
    end
  end

  describe '#future_active' do
    let(:policies) { [future_policy] }
    let(:future_policy) { double(future_active?: true) }

    it 'returns policies that are currently active' do
      expect(subject.future_active).to include(future_policy)
    end
  end

  describe '#is_or_will_be_active' do
    let(:policies) { [active_policy, future_policy] }
    let(:active_policy) { double(currently_active?: true, future_active?: false) }
    let(:future_policy) { double(currently_active?: false, future_active?: true) }

    it 'returns policies that are currently active' do

      expect(subject.is_or_will_be_active).to include(active_policy, future_policy)
    end
  end

  describe '#overlaps_policy' do
    let(:policies) { [ policy_one, policy_two ] }
    let(:policy_one) { double(policy_start: 1, policy_end: 3) }
    let(:policy_two) { double(policy_start: 2, policy_end: 4) }


    it 'returns policies that are currently active' do
      expect(subject.overlaps_policy(policy_one)).to include(policy_one, policy_two)
    end
  end

end
