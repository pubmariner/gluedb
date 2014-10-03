require 'rails_helper'

describe AddEligibilites do
  subject { AddEligibilites.new(person_repo) }

  let(:person_repo) { double(find_by_id: person) }
  let(:person) { Person.new(name_first: 'First', name_last: 'Last') }
  let(:request) do
    {
      assistance_eligibilities: [
        {
          is_primary_applicant: true,
          tax_filing_status: 'tax_filer',
          is_tax_filing_together: true,
          is_enrolled_for_es_coverage: true,
          is_without_assistance: true,
          submission_date: Date.today,
          is_ia_eligible: true,
          is_medicaid_chip_eligible: true,
          incomes: [
            {
              amount_in_cents: 100,
              kind: 'wages_and_salaries',
              frequency: 'biweekly',
              start_date: Date.today.prev_year,
              end_date: Date.today.prev_month,
              is_projected?: false,
              submission_date: Date.today,
              evidence_flag: false,
              reported_by: 'Some Guy'
            }
          ],
          deductions: [
            {
              amount_in_cents: 100,
              kind: 'alimony_paid',
              frequency: 'biweekly',
              start_date: Date.today.prev_year,
              end_date: Date.today.prev_month,
              evidence_flag: true,
              reported_date: Date.today,
              reported_by: 'Some Guy'
            }
          ],
          alternate_benefits: [
            {
              kind: 'medicaid',
              start_date: Date.today.prev_year,
              end_date: Date.today.prev_month,
              submission_date: Date.today
            }
          ]
        }
      ]
    }
  end

  let(:requested_submission_date) { Date.today }

  it 'finds a person' do
    expect(person_repo).to receive(:find_by_id).with(request[:person_id]).and_return(person)
    subject.execute(request)
  end

  it 'adds assistance eligibilities to person' do
    subject.execute(request)

    expect(person.assistance_eligibilities.length).to eq 1

    eligibility = person.assistance_eligibilities.last

    requested_eligibility = request[:assistance_eligibilities].first
    expect(eligibility.is_primary_applicant).to eq requested_eligibility[:is_primary_applicant]
    expect(eligibility.tax_filing_status).to eq requested_eligibility[:tax_filing_status]
    expect(eligibility.is_tax_filing_together).to eq requested_eligibility[:is_tax_filing_together]
    expect(eligibility.is_enrolled_for_es_coverage).to eq requested_eligibility[:is_enrolled_for_es_coverage]
    expect(eligibility.is_without_assistance).to eq requested_eligibility[:is_without_assistance]
    expect(eligibility.submission_date).to eq requested_eligibility[:submission_date]
    expect(eligibility.is_ia_eligible).to eq requested_eligibility[:is_ia_eligible]
    expect(eligibility.is_medicaid_chip_eligible).to eq requested_eligibility[:is_medicaid_chip_eligible]

    income = eligibility.incomes.last 
    requested_income = requested_eligibility[:incomes].first
    expect(income.amount_in_cents).to eq requested_income[:amount_in_cents]
    expect(income.kind).to eq requested_income[:kind]
    expect(income.frequency).to eq requested_income[:frequency]
    expect(income.start_date).to eq requested_income[:start_date]
    expect(income.end_date).to eq requested_income[:end_date]
    expect(income.is_projected?).to eq requested_income[:is_projected?]
    expect(income.submission_date).to eq requested_income[:submission_date]
    expect(income.evidence_flag).to eq requested_income[:evidence_flag]
    expect(income.reported_by).to eq requested_income[:reported_by]

    deduction = eligibility.deductions.last
    requested_deduction = requested_eligibility[:deductions].first
    expect(deduction.amount_in_cents).to eq requested_deduction[:amount_in_cents]
    expect(deduction.kind).to eq requested_deduction[:kind]
    expect(deduction.frequency).to eq requested_deduction[:frequency]
    expect(deduction.start_date).to eq requested_deduction[:start_date]
    expect(deduction.end_date).to eq requested_deduction[:end_date]
    expect(deduction.evidence_flag).to eq requested_deduction[:evidence_flag]
    expect(deduction.reported_by).to eq requested_deduction[:reported_by]

    alt_benefit = eligibility.alternate_benefits.last
    requested_alt_benefit = requested_eligibility[:alternate_benefits].first
    expect(alt_benefit.kind).to eq requested_alt_benefit[:kind]
    expect(alt_benefit.start_date).to eq requested_alt_benefit[:start_date]
    expect(alt_benefit.end_date).to eq requested_alt_benefit[:end_date]
    expect(alt_benefit.submission_date).to eq requested_alt_benefit[:submission_date]
  end

  it 'saves the person' do
    expect(person).to receive(:save!)
    subject.execute(request)
  end

  context 'when eligibility already exists with submission date' do 
    before { person.assistance_eligibilities << AssistanceEligibility.new(submission_date: requested_submission_date)}
    it 'does not add to person' do  
      subject.execute(request)
      expect(person.assistance_eligibilities.count).to eq 1
    end
  end


end
