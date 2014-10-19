require "spec_helper"

describe EventNotification do
  let(:e_pubber) { double }
  subject { EventNotification.new(document, schema, e_pubber) }

  describe "given a schema invalid document" do
    let(:document) { double(:xpath => ["something"]) }
    let(:schema) {
      s = double
      allow(s).to receive(:validate).with(document) { ["whatever"] }
      s
    }

    it { should_not be_valid }
  end

  describe "given a schema valid document which has no event_name tag" do
    let(:document) { 
      event_file = File.open(
        File.join(
          Rails.root,
          "spec",
          "data",
          "example_invalid_event.xml"
        )
      )
      Nokogiri::XML(event_file)
    }
    let(:schema) {
      s = double
      allow(s).to receive(:validate).with(document) { [] }
      s
    }

    it { should_not be_valid }
  end

  describe "given a schema valid document which has an event_name tag" do
    let(:document) { 
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
    let(:schema) {
      s = double
      allow(s).to receive(:validate).with(document) { [] }
      s
    }

    it { should be_valid }

    it "should publish the event when saving" do
      expect(e_pubber).to receive(:publish).with(document)
      subject.save
    end
  end

end
