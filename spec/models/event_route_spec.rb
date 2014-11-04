require 'spec_helper'

describe EventRoute do

  subject { 
    EventRoute.new(
      exchange_kind: exchange_kind,
      exchange_name: exchange_name,
      routing_key: ""
    )
  }
  
  describe "With a default exchange specified" do
    let(:exchange_name) { "whutever" }
    let(:exchange_kind) { "default" }
    let(:default_exchange) { double }

    it "should resolve the correct exchange" do
      channel = double(:default_exchange => default_exchange)
      expect(subject.resolve_exchange(channel)).to eql(default_exchange)
    end
  end

  describe "With a topic exchange specified" do
    let(:exchange_name) { "whutever" }
    let(:exchange_kind) { "topic" }
    let(:topic_exchange) { double }

    it "should resolve the correct exchange" do
      channel = double
      allow(channel).to receive(:topic).with(exchange_name, {:durable => true}).and_return(topic_exchange)
      expect(subject.resolve_exchange(channel)).to eql(topic_exchange)
    end
  end

end

describe EventRoute, "populated from a url" do

    let(:uri) { "amqp:#{exchange_kind}:#{exchange_name}:#{routing_key}" }
    subject {
      EventRoute.from_amqp_uri(uri)
    }

  describe "With a default exchange specified" do
    let(:routing_key) { "default_route" } 
    let(:exchange_name) { "xyzpurple" } 
    let(:exchange_kind) { "default" } 
    let(:default_exchange) { double }

    it "should resolve the correct exchange" do
      channel = double(:default_exchange => default_exchange)
      expect(subject.resolve_exchange(channel)).to eql(default_exchange)
    end

    it "should return the correct routing key" do
      expect(subject.routing_key).to eql(routing_key)
    end
  end

  describe "With a topic exchange specified" do
    let(:routing_key) { "default_route" } 
    let(:exchange_name) { "topic_ex" } 
    let(:exchange_kind) { "topic" } 
    let(:topic_exchange) { double }

    it "should resolve the correct exchange" do
      channel = double
      allow(channel).to receive(:topic).with(exchange_name, {:durable => true}).and_return(topic_exchange)
      expect(subject.resolve_exchange(channel)).to eql(topic_exchange)
    end

    it "should return the correct routing key" do
      expect(subject.routing_key).to eql(routing_key)
    end
  end
end
