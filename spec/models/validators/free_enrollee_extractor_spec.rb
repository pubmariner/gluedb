require 'spec_helper'

describe Validators::FreeEnrolleeExtractor do
  context 'when there are not enough enrollees' do
    let(:enrollees) { [double(rel_code: 'self')]}
    it 'returns none' do
      free_enrollees = Validators::FreeEnrolleeExtractor.new.extract_free_from(enrollees)
      expect(free_enrollees).to eq []
    end
  end
  
  context 'when there are are > 3 children' do
    let(:subscriber) { double("45", age: 45, rel_code: 'self')}
    let(:spouse) { double("45", age: 45, rel_code: 'spouse')}
    let(:costly_one) { double("23", age: 23, rel_code: 'child')}
    let(:costly_two) { double("21", age: 21, rel_code: 'child')}
    let(:costly_three) { double("17", age: 17, rel_code: 'child') }
    let(:costly_four) { double("15", age: 15, rel_code: 'child') }
    let(:free_one) { double("12", age: 12, rel_code: 'child') }
    let(:free_two) { double("9", age: 9, rel_code: 'child') }
    let(:free_three) { double("5", age: 5, rel_code: 'child') }


    let(:enrollees) { [subscriber, spouse, costly_one, costly_two, costly_three, costly_four, free_one, free_two, free_three] }
    it 'returns youngest children under age of 21' do
      costly_enrollees = Validators::FreeEnrolleeExtractor.new.extract_free_from(enrollees)
      expect(costly_enrollees).to include(free_one, free_two, free_three)
      expect(costly_enrollees).not_to include(subscriber, spouse, costly_one, costly_two, costly_three, costly_four)

    end
  end

  context 'when there are are <= 3 children' do
    let(:subscriber) { double("45", age: 45, rel_code: 'self')}
    let(:spouse) { double("45", age: 45, rel_code: 'spouse')}
    let(:costly_one) { double("2", age: 23, rel_code: 'child')}
    let(:costly_two) { double("5", age: 21, rel_code: 'child')}
    let(:costly_three) { double("7", age: 17, rel_code: 'child') }

    let(:enrollees) { [subscriber, spouse, costly_one, costly_two, costly_three] }
    
    it 'returns none' do
      free_enrollees = Validators::FreeEnrolleeExtractor.new.extract_free_from(enrollees)
      expect(free_enrollees).to eq []
    end
  end


end
