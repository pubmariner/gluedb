require 'spec_helper'

describe Parsers::Edi::Etf::PolicyLoop do
  describe 'id' do
    let(:id) { '1234' }
    let(:raw_loop) { {"REFs" => [['', qualifier, id]]} }
    let(:policy_loop) { Parsers::Edi::Etf::PolicyLoop.new(raw_loop) }

    context 'qualified as carrier assigned policy ID' do
      let(:qualifier) { 'X9' }
      it 'returns the id in REF02' do
        expect(policy_loop.id).to eq id
      end
    end

    context 'not qualified as a carrier assigned policy ID' do
      let(:qualifier) { ' ' }
      it 'returns nil' do
        expect(policy_loop.id).to eq nil
      end
    end
  end

  describe 'coverage_start' do
    let(:date) { '19800101'}
    let(:raw_loop) { {"DTPs" => [['', qualifier, '', date]]} }
    let(:policy_loop) { Parsers::Edi::Etf::PolicyLoop.new(raw_loop) }

    context 'qualified as "Benefit Begin"' do
      let(:qualifier) { '348' }
      it 'returns the date from dtp03' do
        expect(policy_loop.coverage_start).to eq date
      end
    end

    context 'not qualified as "Benefit Begin"' do
      let(:qualifier) { ' ' }
      it 'returns nil' do
        expect(policy_loop.coverage_start).to eq nil
      end
    end
  end

  describe 'coverage_end' do
    let(:date) { '19800101'}
    let(:raw_loop) { {"DTPs" => [['', qualifier, '', date]]} }
    let(:policy_loop) { Parsers::Edi::Etf::PolicyLoop.new(raw_loop) }

    context 'qualified as "Benefit End"' do
      let(:qualifier) { '349' }
      it 'returns the date from dtp03' do
        expect(policy_loop.coverage_end).to eq date
      end
    end

    context 'not qualified as "Benefit End"' do
      let(:qualifier) { ' ' }
      it 'returns nil' do
        expect(policy_loop.coverage_end).to eq nil
      end
    end
  end

  describe 'action' do
    let(:raw_loop) { {"HD" => ['', type_code]} }
    let(:policy_loop) { Parsers::Edi::Etf::PolicyLoop.new(raw_loop) }

    context 'given Change type code' do
      let(:type_code) { '001' }
      it 'returns change symbol' do
        expect(policy_loop.action).to eq :change
      end
    end

    context 'given Stop type code' do
      let(:type_code) { '024' }
      it 'returns stop symbol' do
        expect(policy_loop.action).to eq :stop
      end
    end

    context 'given Audit type code' do
      let(:type_code) { '030' }
      it 'returns audit symbol' do
        expect(policy_loop.action).to eq :audit
      end
    end

    context 'given Reinstate type code' do
      let(:type_code) { '025' }
      it 'returns reinstate symbol' do
        expect(policy_loop.action).to eq :reinstate
      end
    end

    context 'given an undefined type code' do
      let(:type_code) { 'undefined' }
      it 'returns add symbol' do
        expect(policy_loop.action).to eq :add
      end

    end

  end

  describe '#eg_id' do
    let(:eg_id) { '1234' }
    let(:raw_loop) { { "REFs" => [['', '1L', eg_id]] } }
    let(:policy_loop) { Parsers::Edi::Etf::PolicyLoop.new(raw_loop) }

    it 'exposes the eg_id from the health coverage loop (2300)' do
      expect(policy_loop.eg_id).to eq eg_id
    end
  end

  describe '#hios_id' do
    let(:hios_id) { '1234' }
    let(:raw_loop) { { "REFs" => [['', 'CE', hios_id]] } }
    let(:policy_loop) { Parsers::Edi::Etf::PolicyLoop.new(raw_loop) }

    it 'exposes the hios_id from the health coverage loop (2300)' do
      expect(policy_loop.hios_id).to eq hios_id
    end
  end

  describe '#canceled?' do
    context 'when start and end date are equal' do
      let(:start_date) { '19800101'}
      let(:end_date) { start_date }
      let(:start_date_qualifier) { '348' }
      let(:end_date_qualifier) { '349' }
      let(:raw_loop) do 
        {
          "DTPs" => [
            ['', start_date_qualifier, '', start_date],
            ['', end_date_qualifier, '', end_date]
          ]
        } 
      end
      let(:policy_loop) { Parsers::Edi::Etf::PolicyLoop.new(raw_loop) }

      it 'is a cancel' do 
        expect(policy_loop.canceled?).to eq true
      end
    end
  end
end
