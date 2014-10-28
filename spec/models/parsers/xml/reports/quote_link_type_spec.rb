# require './app/models/parsers/xml/reports/quote_link_type'
require 'rails_helper'

module Parsers::Xml::Reports
  describe QuoteLinkType do

    let(:namespace) { 'http://openhbx.org/api/terms/1.0' }
    it 'should parse coverage type' do
      quote = Nokogiri::XML("<n1:qhp_quote xmlns:n1=\"#{namespace}\"><n1:coverage_type>urn:openhbx:terms:v1:benefit_coverage#health</n1:coverage_type></n1:qhp_quote>")
      subject = QuoteLinkType.new(quote.root)
      expect(subject.coverage_type).to eq 'health'
    end

    context 'when there is not rate present' do
      it 'should return nil' do
        quote = Nokogiri::XML("<n1:qhp_quote xmlns:n1=\"#{namespace}\"><n1:rates><n1:rate></n1:rate></n1:rates></n1:qhp_quote>")
        subject = QuoteLinkType.new(quote.root)
        expect(subject.rate).to eq nil
      end
    end

    context 'when rate element present' do
      it 'should parse rate' do
        quote = Nokogiri::XML("<n1:qhp_quote xmlns:n1=\"#{namespace}\"><n1:rates><n1:rate><n1:rate>393.64</n1:rate></n1:rate></n1:rates></n1:qhp_quote>")
        subject = QuoteLinkType.new(quote.root)
        expect(subject.rate).to eq '393.64'
      end 
    end

    it 'should parse qhp_id' do
      quote = Nokogiri::XML("<n1:qhp_quote xmlns:n1=\"#{namespace}\"><n1:qhp_id>86052DC0410003-01</n1:qhp_id></n1:qhp_quote>")
      subject = QuoteLinkType.new(quote.root)
      expect(subject.qhp_id).to eq '86052DC0410003'
    end
  end
end