require 'spec_helper'

describe Broker do
  subject(:broker) { build(:broker) }
  [
    :b_type,
    :name_pfx,
    :name_first,
    :name_middle,
    :name_last,
    :name_sfx,
    :name_full,
    :npn,
    :policies,
    :people,
    :employers,
    :carriers,
    :addresses,
    :phones,
    :emails

  ].each do |attribute|
    it { should respond_to attribute }
  end

  describe '.find_or_create' do
    it 'finds an existing broker by broker' do
      exisiting_broker = create :broker
      broker = Broker.new(exisiting_broker.attributes)
      expect(Broker.find_or_create(broker)).to eq exisiting_broker
    end

    it 'creates new broker if existing broker is not found' do
      new_broker = build :broker
      expect(Broker.find_or_create(new_broker)).to eq new_broker
    end
  end

  describe 'validations' do
    describe 'b_type' do
      let(:broker) { build(:broker, :with_invalid_b_type) }
      context 'when invalid' do
        it 'is invalid' do
          expect(broker).to be_invalid
        end
      end

      ['broker', 'tpa'].each do |type|
        context('when ' + type) do
          before { broker.b_type = type}
          it 'is valid' do
            expect(broker).to be_valid
          end
        end
      end
    end
  end

  describe 'finds broker by npn' do
    before { broker.save! }
    context 'provided npn is blank' do
      it 'returns nil' do
        expect(Broker.find_by_npn(nil)).to eq nil
      end
    end

    context 'npn is provided' do
      it 'returns the broker' do
        expect(Broker.find_by_npn(broker.npn)).to eq broker
      end
    end
  end
end
