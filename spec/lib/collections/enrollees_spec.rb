require 'spec_helper'

describe Collections::Enrollees do
  subject { Collections::Enrollees.new(all_enrollees) }

  describe 'filtering by active' do
    let(:active_enrollee) { double(coverage_status: 'active') }
    let(:inactive_enrollee) { double(coverage_status: 'inactive') }
    let(:all_enrollees) { [ active_enrollee, inactive_enrollee ]}
    it 'returns active enrollees' do
      expect(subject.currently_active).to include(active_enrollee)
    end
  end
  describe 'filtering by sharing addresses with person' do
    let(:person) { double }
    let(:matching_enrollee) { double(person: double(addresses_match?: true ))}
    let(:mismatching_enrollee) { double(person: double(addresses_match?: false ))}
    let(:all_enrollees) { [ matching_enrollee, mismatching_enrollee ]}

    it 'returns all enrollees who have matching addresses' do
      expect(subject.shares_addresses_with(person)).to include(matching_enrollee)
    end

  end

  describe 'selecting children' do
    let(:all_enrollees) { [child_one, child_two, subscriber, spouse] }
    let(:child_one) { double(rel_code: 'child') }
    let(:child_two) { double(rel_code: 'child') }
    let(:subscriber) { double(rel_code: 'self') }
    let(:spouse) { double(rel_code: 'spouse') }

    it 'returns enrollees with relationship of child' do 
      expect(subject.children).to include(child_one, child_two)
    end
  end
  
  describe 'within age' do
    let(:all_enrollees) { [over_age, in_range_one, in_range_two] }
    let(:over_age) { double(age: 40) }
    let(:in_range_one) { double(age: 5) }
    let(:in_range_two) { double(age: 20) }

    it 'returns enrollees within a specified age range' do
      expect(subject.within_age_range(0...21)).to include(in_range_one, in_range_two)
      expect(subject.within_age_range(0...21)).not_to include(over_age)
    end
  end

end
