require 'rails_helper'

module Generators::Reports
  describe IrsGroupBuilder do

    subject { IrsGroupBuilder.new(family) }

    let(:months) { 3 }
    let(:calender_month) { 1 }
    let(:family) { double(households: households) }
    let(:households) { [household1, household2] }
    let(:household1) { double(tax_households: [double, double]) }
    let(:household2) { double }

    let(:mock_household) { PdfTemplates::Household.new }
    let(:mock_taxhousehold) { PdfTemplates::TaxHousehold.new }
    let(:mock_household_coverage) { PdfTemplates::TaxHouseholdCoverage.new }
    let(:mock_member) { double }
    let(:mock_tax_member) { PdfTemplates::Enrollee.new }
    let(:tax_household) { double(primary: double, spouse: double, dependents: []) }

    # context 'tax household' do
    #   it 'should have same number of coverages as number of months' do
    #     allow(subject).to receive(:build_household_coverage).and_return(mock_household_coverage)

    #     household = subject.build_taxhousehold(tax_household)
    #     expect(household.tax_household_coverages.count).to eq(months)
    #   end
    # end

    # context 'tax household coverage' do 
    #   it 'should build coverage for the calender month' do 
    #     allow(subject).to receive(:build_tax_member).and_return(mock_tax_member)
    #     allow(tax_household).to receive(:coverage_as_of).and_return( [])

    #     coverage = subject.build_household_coverage(tax_household, calender_month)
    #     expect(coverage).to be_kind_of(PdfTemplates::TaxHouseholdCoverage)
    #     expect(coverage.calender_month).to eq(calender_month)
    #   end
    # end

    context 'tax household member builder' do
      let(:household_member) { double(family_member: family_member)}
      let(:family_member) { double(person: person)}
      let(:person) { double(authority_member: nil)}

      context 'when household member passed is nil' do 
        let(:household_member) { nil }

        it 'should return nil' do 
          tax_member = subject.build_tax_member(household_member)
          expect(tax_member).to be_nil 
        end
      end 

      context 'when household member passed has no authority member set' do 

        it 'should return nil' do 
          tax_member = subject.build_tax_member(household_member)
          expect(tax_member).to be_nil 
        end
      end

      context 'when household member passed is a valid member' do
        let(:person) { double(authority_member: member, full_name: 'mark', name_first: 'mark', name_middle: '', name_last: '', name_sfx: '')}
        let(:member) { double(ssn: '3742322320', dob: Date.parse('12/19/1983') )}

        it 'should return enrollee template object' do
          allow(subject).to receive(:build_address).and_return(nil)

          tax_member = subject.build_tax_member(household_member)
          expect(tax_member).to be_kind_of(PdfTemplates::Enrollee)     
        end
      end
    end

    context '.build_taxhouseholds_from_enrollments' do 
      subject { IrsGroupBuilder.new(family) }

      let(:family) { double(households: [ household ]) }
      let(:household) { double }
      let(:enrollments) { [ enrollment ] }
      let(:enrollment) { double(policy: policy) }
      let(:policy) { double(id: 232323, subscriber: enrollee1, spouse: enrollee2, dependents: [enrollee3, enrollee4], applied_aptc: 100.0) }
      let(:enrollee1) { double(person: primary)}
      let(:enrollee2) { double(person: spouse)}
      let(:enrollee3) { double(person: son1)}
      let(:enrollee4) { double(person: daughter1)}

      let(:primary) { double(id: 100, authority_member: primary_member, full_name: 'john smith', name_first: 'john', name_middle: '', name_last: 'smith', name_sfx: '', addresses: [address])}
      let(:primary_member) { double(ssn: '3742322325', dob: Date.parse('12/19/1983') )}

      let(:spouse) { double(id: 101, authority_member: spouse_member, full_name: 'sarah smith', name_first: 'sarah', name_middle: '', name_last: 'smith', name_sfx: '', addresses: [])}
      let(:spouse_member) { double(ssn: '3742322326', dob: Date.parse('12/19/1987') )}

      let(:son1) { double(id: 102, authority_member: son1_member, full_name: 'blair smith', name_first: 'blair', name_middle: '', name_last: 'smith', name_sfx: '', addresses: [])}
      let(:son1_member) { double(ssn: '3742322327', dob: Date.parse('12/19/2007') )}

      let(:daughter1) { double(id: 103, authority_member: daughter1_member, full_name: 'rose smith', name_first: 'rose', name_middle: '', name_last: 'smith', name_sfx: '', addresses: [])}
      let(:daughter1_member) { double(ssn: '3742322328', dob: Date.parse('12/19/2010') )}

      let(:address) { double(address_1: '100 H ST NW', address_2: '', city: 'washington dc', state: 'DC', zip: '20002') }

      let(:calender_year) { '2014' }

      before :each do
        subject.calender_year = calender_year 
        allow(household).to receive(:enrollments_for_year).with(calender_year).and_return(enrollments)
      end

      context 'when single aptc policy present' do
        it 'should return single tax household with policy primary applicant as tax primary' do 
          result = subject.build_taxhouseholds_from_enrollments(household)

          expect(result.count).to eq 1
          expect(result.first).to be_kind_of(PdfTemplates::TaxHousehold)
          expect(result.first.primary.name).to eq primary.full_name
          expect(result.first.spouse.name).to eq spouse.full_name
          expect(result.first.dependents.count).to eq policy.dependents.count
          expect(result.first.dependents.first.name).to eq son1.full_name
          expect(result.first.dependents.last.name).to eq daughter1.full_name
        end
      end

      context 'when multiple aptc policies present with same primary applicant' do
        let(:policy) { double(id: 232323, subscriber: enrollee1, spouse: nil, dependents: [enrollee3], applied_aptc: 100.0) }
        let(:policy1) { double(id: 232323, subscriber: enrollee1, spouse: enrollee2, dependents: [enrollee4], applied_aptc: 0.0) }
        let(:enrollments) { [ enrollment, enrollment1 ] }
        let(:enrollment1) { double(policy: policy1) }
 
        it 'should return single tax household with policy primary applicant as tax primary' do 
          result = subject.build_taxhouseholds_from_enrollments(household)

          expect(result.count).to eq 1
          expect(result.first).to be_kind_of(PdfTemplates::TaxHousehold)
          expect(result.first.primary.name).to eq primary.full_name
          expect(result.first.spouse.name).to eq spouse.full_name
          expect(result.first.dependents.count).to eq 2
          expect(result.first.dependents.first.name).to eq son1.full_name
          expect(result.first.dependents.last.name).to eq daughter1.full_name 
        end
      end

      context 'when multiple aptc policies present with different primary applicant' do
        let(:policy) { double(id: 232323, subscriber: enrollee1, spouse: nil, dependents: [enrollee3], applied_aptc: 100.0) }
        let(:policy1) { double(id: 232323, subscriber: enrollee2, spouse: nil, dependents: [enrollee4], applied_aptc: 0.0) }
        let(:enrollments) { [ enrollment, enrollment1 ] }
        let(:enrollment1) { double(policy: policy1) }

        it 'should return single tax household with policy primary applicant as tax primary' do 
          result = subject.build_taxhouseholds_from_enrollments(household)

          expect(result.count).to eq 2
          expect(result.first).to be_kind_of(PdfTemplates::TaxHousehold)
          expect(result.first.primary.name).to eq primary.full_name
          expect(result.last.primary.name).to eq spouse.full_name
          expect(result.first.dependents.count).to eq policy.dependents.count
          expect(result.last.dependents.count).to eq policy1.dependents.count
          expect(result.first.dependents.first.name).to eq son1.full_name
          expect(result.last.dependents.first.name).to eq daughter1.full_name 
        end
      end


      context 'when multiple aptc policies present with different primary applicant' do
        let(:policy) { double(id: 232323, subscriber: enrollee1, spouse: enrollee2, dependents: [enrollee3], applied_aptc: 100.0) }
        let(:policy1) { double(id: 232323, subscriber: enrollee2, spouse: enrollee1, dependents: [enrollee4], applied_aptc: 0.0) }
        let(:enrollments) { [ enrollment, enrollment1 ] }
        let(:enrollment1) { double(policy: policy1) }

        it 'should return single tax household with policy primary applicant as tax primary' do 
          result = subject.build_taxhouseholds_from_enrollments(household)

          expect(result.count).to eq 1
          expect(result.first).to be_kind_of(PdfTemplates::TaxHousehold)
          expect(result.first.primary.name).to eq primary.full_name
          expect(result.first.spouse.name).to eq spouse.full_name
          expect(result.first.dependents.count).to eq 2
          expect(result.first.dependents.first.name).to eq son1.full_name
          expect(result.first.dependents.last.name).to eq daughter1.full_name 
        end
      end
    end
  end
end