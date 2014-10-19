require 'spec_helper'

describe EventParser do
  subject { EventParser.parse(event) }

  describe "given an event" do
    let(:event) {
      event_file = File.open(
        File.join(
          Rails.root,
          "spec",
          "data",
          "example_valid_event.xml"
        )
      )
      Nokogiri::XML(event_file)
    }
    let(:event_uri) { "urn:openhbx:events:v1:employers_employees#qhp_selected" }
    let(:message_headers) { {:headers=>{"event_name"=>"urn:openhbx:events:v1:employers_employees#qhp_selected", "qualifying_reason"=>"", "employer_uri"=>"", "enrollment_group_uri"=>"", "hbx_id"=>"DC0", "submitted_timestamp"=>"2014-03-07T12:00:00Z", "authorization"=>"", "originating_service"=>"orig_serv"}, "message_id"=>"msg_id"} }

    it "should parse the correct event_uri" do
      expect(subject.event_uri).to eq event_uri
    end

    it "should parse the correct message_headers" do
      expect(subject.message_headers).to eq message_headers
    end

    it "should parse the correct message_body" do
      expect(subject.message_body).to eq nil
    end
  end
end
