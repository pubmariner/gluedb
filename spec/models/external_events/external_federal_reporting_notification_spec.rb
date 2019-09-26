require 'rails_helper'

describe ExternalEvents::ExternalFederalReportingNotification do
  let(:today) { Time.mktime(2025, 1, 1) }
  let(:object) {{
                  bucket: "examplebucket", 
                  key: "HappyFace.jpg", 
                }}
  let(:uri) { "urn:openhbx:terms:v1:file_storage:s3:bucket:-tax-documents-preprod" }
  let(:s3_response) { {object: object, uri: uri} }
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
            :file_name =>  s3_response[:object][:key],
            :policy_id => policy.id,
            :eg_id => policy.eg_id
          },
          :routing_key => "info.events.transport_artifact.transport_requested"
        },
        ""
      )
    end
  end

end