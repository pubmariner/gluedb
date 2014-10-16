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

    let(:etu_double) { double({ :save => true }) }

    before :each do
       user = double('user')
       allow(request.env['warden']).to receive(:authenticate!).and_return(user)
       allow(controller).to receive(:current_user).and_return(user)
       allow(EnrollmentTransmissionUpdate).to receive(:new).and_return(etu_double)
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
