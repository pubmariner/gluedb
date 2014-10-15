require 'rails_helper'
require 'savon'

describe Soap::V1::PeopleController do

  before(:all) do
    @client = Savon::Client.new(wsdl: "http://localhost:3000/soap/v1/people/wsdl?user_token=zUzBsoTSKPbvXCQsB4Ky")
  end

  describe "index service" do

    context "Valid Params in index" do
      it "makes a successful call" do
        result = @client.call(:index, message: {"page" => "1", "hbx_id" => "177772", "user_token" => "zUzBsoTSKPbvXCQsB4Ky"})
        expect(result.success?).to eq(true)
      end
    end

    context "Authentication failure" do
      it "should raise HTTP 401 error" do
        expect { @client.call(:index, message: {"page" => "1", "hbx_id" => "177772", "user_token" => "zUzBsoTSKPbvXCQsB4Ky00"}) }.to raise_error(Savon::HTTPError) { |e| puts expect(e.http.code).to eq(401) }
        expect { @client.call(:index, message: {"page" => "1", "hbx_id" => "177772", "user_token" => ""}) }.to raise_error(Savon::HTTPError) { |e| puts expect(e.http.code).to eq(401) }
      end
    end

    context "Missing hbx_id" do
      it "should raise HTTP 422 error" do

        expect { @client.call(:index, message: {"page" => "1", "user_token" => "zUzBsoTSKPbvXCQsB4Ky"}) }.to raise_error(Savon::HTTPError) { |e| puts expect(e.http.code).to eq(422) }
        expect { @client.call(:index, message: {"page" => "1", "hbx_id" => "", "user_token" => "zUzBsoTSKPbvXCQsB4Ky"}) }.to raise_error(Savon::HTTPError) { |e| puts expect(e.http.code).to eq(422) }

      end
    end

  end

  describe "show service" do



    context "Valid Params" do
      it "makes a successful call" do
        result = @client.call(:show, message: {"id" => "53e69d73eb899ad9ca053ada", "user_token" => "zUzBsoTSKPbvXCQsB4Ky"})
        expect(result.success?).to eq(true)
      end
    end

    context "Authentication failure" do
      it "should raise HTTP 401 error" do
        expect { @client.call(:index, message: {"id" => "53e69d73eb899ad9ca053ada", "user_token" => "zUzBsoTSKPbvXCQsB4Ky00"}) }.to raise_error(Savon::HTTPError) { |e| puts expect(e.http.code).to eq(401) }
        expect { @client.call(:index, message: {"id" => "53e69d73eb899ad9ca053ada", "user_token" => ""}) }.to raise_error(Savon::HTTPError) { |e| puts expect(e.http.code).to eq(401) }

      end
    end

    context "Missing hbx_id" do
      it "should raise HTTP 422 error" do

        expect { @client.call(:index, message: {"user_token" => "zUzBsoTSKPbvXCQsB4Ky"}) }.to raise_error(Savon::HTTPError) { |e| puts expect(e.http.code).to eq(422) }
        expect { @client.call(:index, message: {"hbx_id" => "", "user_token" => "zUzBsoTSKPbvXCQsB4Ky"}) }.to raise_error(Savon::HTTPError) { |e| puts expect(e.http.code).to eq(422) }

      end
    end

  end

end