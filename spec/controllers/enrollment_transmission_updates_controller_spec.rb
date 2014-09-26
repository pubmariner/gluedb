require_relative "../rails_helper"

describe EnrollmentTransmissionUpdatesController do
  describe "post #create" do
    let(:enrollment_transmission_update_properties) {
      {
        "path" => "whatever",
        "transmission_kind" => "maintenance",
        "data" => "0001010101 beep boop data!"
      }
    }

    let(:etu_double) { double("enrollment_transmission_update") }

    before :each do
       user = double('user')
       request.env['warden'].stub :authenticate! => user
       controller.stub :current_user => user
       EnrollmentTransmissionUpdate.stub(:new).and_return(etu_double)
       etu_double.stub(:save)
    end

    it "instantiates and saves a new EnrollmentTransmissionUpdate" do
      expect(EnrollmentTransmissionUpdate).to receive(:new).with(enrollment_transmission_update_properties).and_return(etu_double)
      expect(etu_double).to receive(:save)
      post :create, :enrollment_transmission_update => enrollment_transmission_update_properties
    end

    it "returns ok" do
      post :create, :enrollment_transmission_update => enrollment_transmission_update_properties
      expect(response).to be_ok
    end
  end
end
