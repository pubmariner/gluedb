require 'rails_helper'
require 'savon'

describe Soap::V1::EmployersController do

  before(:all) do
    @client = Savon::Client.new(wsdl: "http://localhost:3000/soap/v1/employers/wsdl?user_token=zUzBsoTSKPbvXCQsB4Ky")
  end

  describe "index service" do

    context "Valid Params in index" do
      it "makes a successful call" do
        result = @client.call(:index, message: {"page" => "1", "hbx_id" => "100102", "fein"=>"536002558", "user_token" => "zUzBsoTSKPbvXCQsB4Ky"})
        expect(result.success?).to eq(true)
      end

      it "should check for valid xml in response" do
        result = @client.call(:index, message: {"page" => "1", "hbx_id" => "100102", "fein"=>"536002558", "user_token" => "zUzBsoTSKPbvXCQsB4Ky"})
        doc = Nokogiri::XML(result.body.to_xml)
        expect(doc.errors.blank?).to eq(true)
      end

    end

    context "Authentication failure" do
      it "should raise HTTP 401 error" do
        expect { @client.call(:index, message: {"page" => "1", "hbx_id" => "100102", "fein"=>"536002558", "user_token" => "zUzBsoTSKPbvXCQsB4Ky00"}) }.to raise_error(Savon::HTTPError) { |e| puts expect(e.http.code).to eq(401) }
        expect { @client.call(:index, message: {"page" => "1", "hbx_id" => "100102", "fein"=>"536002558", "user_token" => ""}) }.to raise_error(Savon::HTTPError) { |e| puts expect(e.http.code).to eq(401) }
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
        result = @client.call(:show, message: {"id" => "53e6731deb899a460302a120", "user_token" => "zUzBsoTSKPbvXCQsB4Ky"})
        expect(result.success?).to eq(true)
      end

      it "should check for valid xml in response" do
        result = @client.call(:show, message: {"id" => "53e6731deb899a460302a120", "user_token" => "zUzBsoTSKPbvXCQsB4Ky"})
        doc = Nokogiri::XML(result.body.to_xml)
        expect(doc.errors.blank?).to eq(true)
      end

    end

    context "Authentication failure" do
      it "should raise HTTP 401 error" do
        expect { @client.call(:show, message: {"id" => "53e6731deb899a460302a120", "user_token" => "zUzBsoTSKPbvXCQsB4Ky00"}) }.to raise_error(Savon::HTTPError) { |e| puts expect(e.http.code).to eq(401) }
        expect { @client.call(:show, message: {"id" => "53e6731deb899a460302a120", "user_token" => ""}) }.to raise_error(Savon::HTTPError) { |e| puts expect(e.http.code).to eq(401) }

      end
    end

    context "Missing hbx_id" do
      it "should raise HTTP 422 error" do

        expect { @client.call(:show, message: {"user_token" => "zUzBsoTSKPbvXCQsB4Ky"}) }.to raise_error(Savon::HTTPError) { |e| puts expect(e.http.code).to eq(422) }
        expect { @client.call(:show, message: {"id" => "", "user_token" => "zUzBsoTSKPbvXCQsB4Ky"}) }.to raise_error(Savon::HTTPError) { |e| puts expect(e.http.code).to eq(422) }

      end
    end

  end

end