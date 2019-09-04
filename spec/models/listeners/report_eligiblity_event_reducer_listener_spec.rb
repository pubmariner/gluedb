require 'rails_helper'

describe Listeners::ReportEligiblityEventReducerListener do
  let(:policy) { double }
  let(:policy_id) { "12" }
  let(:policy_eg_id) { "34" }

  let(:message_body) { "" }
  let(:message_properties) { double(:headers => message_headers) }
  let(:message_headers) { { :policy_id => policy_eg_id, timestamp: time_provider } }
  let(:connection) { double }
  let(:channel) { double(:connection => connection) }
  let(:queue) { double }
  let(:message_tag) { "a message tag" }
  let(:delivery_info) { double(:delivery_tag => message_tag) }
  let(:mock_requestor) { double }
  let(:r_di) { double }
  let(:error_channel) { double(:close =>  nil) }
  let(:mock_event_exchange_name) { "mock event exchange name" }
  let(:mock_event_exchange) { double }
  let(:time_provider) { double( :now => 1 ) }

  subject { Listeners::ReportEligiblityEventReducerListener.new(channel,queue) }

  before :each do
    allow(ExchangeInformation).to receive(:event_publish_exchange).and_return(mock_event_exchange_name)
    allow(Amqp::Requestor).to receive(:new).with(connection).and_return(mock_requestor)
    allow(Policy).to receive(:find).with(policy_eg_id).and_return(policy)
  end

  describe "given a broker which doesn't exist" do

    before :each do
    end

    describe "with valid new broker info" do
      let(:valid_broker_value) { true }

      it "should create that broker" do
        subject.on_message(delivery_info, message_properties, message_body)
      end
    end
end
end


