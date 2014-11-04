require 'rails_helper'

describe Validators::PremiumValidator do
  subject(:validator) { Validators::PremiumValidator.new(change_request, plan, listener) }

  let(:change_request) { double }
  let(:plan) { double }
  let(:listener) { double }

  context 'premium does not match plan premium' do
    before do
      allow(plan).to receive(:premium_for_enrollee).and_return(double(amount: 22.0))

      allow(change_request).to receive(:enrollees).and_return(
        [ double(premium_amount: 666.66, name: 'Name', rel_code: 'self') ]
      )
    end
    it 'notifies the listener' do
      expect(listener).to receive(:enrollee_has_incorrect_premium).with({name: 'Name', provided: 666.66, expected: 22.0})
      expect(validator.validate).to eq false
    end
  end

  context 'premium matches plan premium' do
    before do
      allow(plan).to receive(:premium_for_enrollee).and_return(double(amount: 22.0))
      allow(change_request).to receive(:enrollees).and_return(
        [ double(premium_amount: 22.0, name: 'Name', rel_code: 'self') ]
      )
    end
    it 'does not notify the listener' do
      expect(listener).not_to receive(:enrollee_has_incorrect_premium)
      expect(validator.validate).to eq true
    end
  end

  context 'when there are >5 enrollees' do
    before do
      enrollees = []
      enrollees << double(age: 40, premium_amount: 22.0, rel_code: 'self')
      3.times { enrollees << double(age: 14, premium_amount: 22.0, rel_code: 'child') }
      enrollees << youngest

      allow(plan).to receive(:premium_for_enrollee).and_return(double(amount: 22.0))
      allow(change_request).to receive(:enrollees).and_return(enrollees)
    end

    context 'and youngest isnt free' do
      let(:youngest) { double(age: 1, premium_amount: 22.0, name: 'Name', rel_code: 'child') }
      it 'notifies listener that the premium is incorrect' do
        expect(listener).to receive(:enrollee_has_incorrect_premium).with({name: 'Name', provided: 22.0, expected: 0})
        expect(validator.validate).to eq false
      end
    end

    context 'and youngest is free' do
      let(:youngest) { double(age: 1, premium_amount: 0.0, name: 'Name', rel_code: 'child') }
      it 'does NOT notifies listener that the premium is incorrect' do
        expect(listener).not_to receive(:enrollee_has_incorrect_premium)
        expect(validator.validate).to eq true
      end
    end
  end
end
