require 'rails_helper'

describe Validators::PlanValidator do 
  subject(:validator) { Validators::PlanValidator.new(change_request,plan,listener) }

  let(:change_request) { double }
  let(:plan) { double }
  let(:listener) { double }

  context 'when the plan is found' do 
    before do
      allow(plan).to receive(:blank?).and_return(false)
    end
    it 'does not notify the listener' do
      expect(listener).not_to receive(:plan_not_found)
    end
    it 'validates to true' do 
      expect(validator.validate).to eq true
    end
  end

  context 'when the plan is not found' do 
    before do
      allow(plan).to receive(:blank?).and_return(true)
    end
    it 'notifies the listener' do
      expect(listener).to receive(:plan_not_found)
      listener.plan_not_found
    end
    it 'validates to false' do 
      expect(validator.validate).to eq false
    end
  end

end