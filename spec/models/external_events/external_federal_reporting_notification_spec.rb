require 'rails_helper'

describe ExternalEvents::ExternalFederalReportingNotification do
  let(:today) { Time.mktime(2025, 1, 1) }
  let(:object) {double(bucket: "examplebucket", key: "HappyFace", )}
  let(:uri) { "urn:openhbx:terms:v1:file_storage:s3:bucket:-tax-documents-preprod" }
  let(:full_file_name) {"HappyFace"}
  let(:s3_response) { {object: object, uri: uri, full_file_name: full_file_name} }
  let(:policy) { instance_double(Policy, eg_id: "1", id: "2")}
  let(:event_broadcaster) { instance_double(Amqp::EventBroadcaster) }
  let(:subject) { ExternalEvents::ExternalFederalReportingNotification   }
  before(:each) do
    allow(Amqp::EventBroadcaster).to receive(:with_broadcaster).and_yield(event_broadcaster)
    allow(event_broadcaster).to receive(:broadcast).and_return(s3_response)
  end

  context "after receiving an s3 object" do
    it "sends the message" do
      ExternalEvents::ExternalFederalReportingNotification.notify(s3_response, policy, today)

      expect(event_broadcaster).to have_received(:broadcast).with(
        {
          :headers => {
              :file_name=>"HappyFace",
              :policy_id=>"2",
              :eg_id=>"1",
              :artifact_key=>"HappyFace",
              :transport_process=>"TransportProfiles::Processes::PushReportEligibilityUpdatedH41"
          },
          :routing_key => "info.events.transport_artifact.transport_requested"
        },
        ""
      )
    end
  end

end
