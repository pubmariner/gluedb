require 'rails_helper'
# require './app/models/parsers/xml/reports/policy_link_type'

module Parsers::Xml::Reports
  describe PolicyLinkType do

    let(:namespace) { 'http://openhbx.org/api/terms/1.0' }
    let(:policy_xml) { "<n1:policy xmlns:n1=\"#{namespace}\">\"#{policy_id}#{enrollees}#{employer}\"</n1:policy>" }
    let(:policy_id) { "<n1:id>http://localhost:3000/api/v1/policies/8461</n1:id>" }
    let(:enrollees) { "<n1:enrollees><n1:enrollee>\"#{benefit}\"</n1:enrollee></n1:enrollees>" }
    let(:benefit) { "<n1:benefit>\"#{begin_date}#{end_date}\"</n1:benefit>" }
    let(:begin_date) { "<n1:begin_date>20140301</n1:begin_date>" }
    let(:end_date) { "<n1:end_date>20141212</n1:end_date>"}
    let(:employer) { "<n1:employer></n1:employer>" }

    it 'should parse policy id' do
      policy = Nokogiri::XML(policy_xml)
      subject = PolicyLinkType.new(policy.root)
      expect(subject.id).to eq 'http://localhost:3000/api/v1/policies/8461'
    end

    context 'individual market' do
      context 'when employer not present' do
        let(:employer) { nil }
        it 'should return true' do
          policy = Nokogiri::XML(policy_xml)
          subject = PolicyLinkType.new(policy.root)
          expect(subject.individual_market?).to eq true
        end 
      end

      context 'when employer present' do
        it 'should return false' do
          policy = Nokogiri::XML(policy_xml)
          subject = PolicyLinkType.new(policy.root)
          expect(subject.individual_market?).to eq false
        end
      end
    end              

    context 'begin date' do
      context 'when not present' do
        let(:begin_date) { nil }
        it 'should return nil' do
          policy = Nokogiri::XML(policy_xml)
          subject = PolicyLinkType.new(policy.root)
          expect(subject.begin_date).to eq nil
        end
      end

      context 'when present' do
        it 'should return date' do
          policy = Nokogiri::XML(policy_xml)
          subject = PolicyLinkType.new(policy.root)
          expect(subject.begin_date).to eq Date.strptime('20140301', '%Y%m%d')
        end
      end
    end

    context 'end date' do
      context 'when not present' do
        let(:end_date) { nil }
        it 'should return nil' do
          policy = Nokogiri::XML(policy_xml)
          subject = PolicyLinkType.new(policy.root)
          expect(subject.end_date).to eq nil
        end
      end

      context 'when present' do
        it 'should return date' do
          policy = Nokogiri::XML(policy_xml)
          subject = PolicyLinkType.new(policy.root)
          expect(subject.end_date).to eq Date.strptime('20141212', '%Y%m%d')
        end
      end
    end

    context 'policy state' do
      context 'when begin date and end dates are same' do
        let(:end_date) { "<n1:end_date>20140301</n1:end_date>" }
        it 'should return inactive' do
          policy = Nokogiri::XML(policy_xml)
          subject = PolicyLinkType.new(policy.root)
          expect(subject.state).to eq 'inactive'
        end
      end

      context 'when begin date is after renewal year start date' do
        let(:begin_date) { "<n1:begin_date>20150101</n1:begin_date>" }
        it 'should return inactive' do 
          policy = Nokogiri::XML(policy_xml)
          subject = PolicyLinkType.new(policy.root)
          expect(subject.state).to eq 'inactive'
        end
      end

      context 'when begin date is before renewal year start date and' do
        context 'end date not present' do
          let(:end_date) { nil }
          it 'should return active' do
            policy = Nokogiri::XML(policy_xml)
            subject = PolicyLinkType.new(policy.root)
            expect(subject.state).to eq 'active'
          end
        end

        context 'end date is after renewal year start date' do
          let(:end_date) { "<n1:end_date>20150101</n1:end_date>" }
          it 'should return true' do
            policy = Nokogiri::XML(policy_xml)
            subject = PolicyLinkType.new(policy.root)
            expect(subject.state).to eq 'active'           
          end
        end

        context 'end date is before renewal year start date' do
          it 'should return false' do
            policy = Nokogiri::XML(policy_xml)
            subject = PolicyLinkType.new(policy.root)
            expect(subject.state).to eq 'inactive'            
          end
        end
      end
    end
  end
end