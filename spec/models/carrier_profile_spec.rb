require 'rails_helper'

describe CarrierProfile do
  [:fein, :profile_name, :requires_reinstate_for_earlier_termination].each do |attribute|
    it { should respond_to attribute }
  end
  it 'should default the uses_issuer_centric_sponsor_cycles to false' do
    expect(CarrierProfile.new.requires_reinstate_for_earlier_termination).to eq false
  end
end