require 'rails_helper'

describe Validators::PremiumTotalValidator do
  let(:validator) { Validators::PremiumTotalValidator.new(change_request, listener) }
  let(:change_request) { double }
  let(:listener) { double }

  context 'when total premium is incorrect' do
    before do
      allow(change_request).to receive(:enrollee_premium_sum).and_return(325.251)
      allow(change_request).to receive(:premium_amount_total).and_return(666.66)
    end
    it 'notifies listener' do
      expect(listener).to receive(:group_has_incorrect_premium_total).with({provided: 666.66, expected: 325.25})
      expect(validator.validate).to eq false
    end
  end

  context 'when total premium is correct' do
    before do
      allow(change_request).to receive(:enrollee_premium_sum).and_return(325.251)
      allow(change_request).to receive(:premium_amount_total).and_return(325.25)
    end
    it 'does not notify listener' do
      expect(listener).not_to receive(:group_has_incorrect_premium_total)
      expect(validator.validate).to eq true
    end
  end
end
