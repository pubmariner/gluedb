require 'rails_helper'
# require './app/models/canonical_vocabulary/renewals/renewal_report_row_builder'

module CanonicalVocabulary::Renewals
  describe RenewalReportRowBuilder do
    subject { RenewalReportRowBuilder.new(app_group, primary) }
    let(:app_group) { double(integrated_case: '1234', yearwise_incomes: "250000", irs_consent: nil, size: 2) }
    let(:primary) { double(addresses: addresses)}
    let(:member) { double(name_first: 'Joe', name_last: 'Riden', age: 30, citizenship: 'US Citizen', tax_status: 'Single', mec: nil, yearwise_incomes: '120000', incarcerated: false) }
    let(:policy) { double(current: current, future_plan_name: 'Best Plan', quoted_premium: "12.21") }
    let(:current) { {plan: double} }
    let(:notice_date) { double }
    let(:addresses) { [ address ] }
    let(:address) { {address_1: 'Wilson Building', address_2: 'K Street', apt: 'Suite 100', city: 'Washington DC', state: state, postal_code: '20002'} }
    let(:state) { 'DC'}
    let(:response_date) { double }
    let(:aptc) { nil }
    let(:post_aptc_premium) { nil }

    it 'can append integrated case numbers' do
      subject.append_integrated_case_number

      expect(subject.data_set).to include app_group.integrated_case
    end

    it 'can append name of a member' do
      subject.append_name_of(member)

      expect(subject.data_set).to include member.name_first
      expect(subject.data_set).to include member.name_last
    end

    it 'can append notice date' do
      subject.append_notice_date(notice_date)
      expect(subject.data_set).to include notice_date
    end

    it 'can append household address' do 
      subject.append_household_address
      expect(subject.data_set).to eq [addresses[0][:address_1], addresses[0][:address_2], addresses[0][:apt], addresses[0][:city], addresses[0][:state], addresses[0][:postal_code]]
    end

    it 'can append aptc' do
      subject.append_aptc
      expect(subject.data_set).to include aptc
    end

    it 'can append response date' do
      subject.append_notice_date(response_date)
      expect(subject.data_set).to include response_date
    end

    context 'when there is a current policy' do
      let(:current) { {plan: double} }
      it 'can append policy' do
        subject.append_policy(policy)
        expect(subject.data_set).to eq [policy.current[:plan], policy.future_plan_name, policy.quoted_premium]
      end
    end

    context 'when there is no current policy' do
      let(:current) { nil }
      it 'appends policy with nil current plan' do
        subject.append_policy(policy)
        expect(subject.data_set).to eq [policy.current, policy.future_plan_name, policy.quoted_premium]
      end
    end

    it 'can append post aptc premium' do
      subject.append_post_aptc_premium
      expect(subject.data_set).to include post_aptc_premium
    end

    it 'can append financials' do
      subject.append_financials
      expect(subject.data_set).to eq [app_group.yearwise_incomes, nil, app_group.irs_consent]
    end

    it 'can append age' do 
      subject.append_age_of(member)
      expect(subject.data_set).to include member.age
    end

    context 'when there is residency' do
      let(:member) { double(residency: 'D.C. Resident')}
      it 'appends residency' do
        subject.append_residency_of(member)
        expect(subject.data_set).to include member.residency 
      end
    end

    context 'residency status not available' do 
      let(:member) { double(residency: nil)}

      context 'when both address' do
        let(:address) { nil }
        it 'appends no status' do
          subject.append_residency_of(member)
          expect(subject.data_set).to include "No Status" 
        end
      end

      context 'when D.C address present' do
        let(:state) { 'DC' }
        it 'appends dc resident if address belongs to dc' do
          subject.append_residency_of(member)
          expect(subject.data_set).to include "D.C. Resident" 
        end
      end

      context 'when non D.C address present' do
        let(:state) { 'VA' }
        it 'appends non dc resident if address is outside of dc' do
          subject.append_residency_of(member)
          expect(subject.data_set).to include "Not a D.C Resident"  
        end
      end
    end

    it 'can append citizenship' do
      subject.append_citizenship_of(member)
      expect(subject.data_set).to include member.citizenship
    end

    it 'can append tax status' do
     subject.append_tax_status_of(member)
     expect(subject.data_set).to include member.tax_status
    end
   
    it 'can append mec' do
      subject.append_mec_of(member)
      expect(subject.data_set).to include member.mec
    end

    it 'can append group size' do
      subject.append_app_group_size
      expect(subject.data_set).to include app_group.size 
    end

    it 'can append yearly income' do
      subject.append_yearwise_income_of(member)
      expect(subject.data_set).to include member.yearwise_incomes 
    end

    it 'can append blank' do
      subject.append_blank
      expect(subject.data_set).to include nil
    end

    it 'can append incarcerated status' do
      subject.append_incarcerated(member)
      expect(subject.data_set).to include member.incarcerated 
    end
  end
end