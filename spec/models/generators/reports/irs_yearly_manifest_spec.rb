require 'rails_helper'

describe Generators::Reports::IrsYearlyManifest, :dbclean => :after_each do
  # TODO: Make this spec more robust. This just tests adding attr_accessor
  context "initializes with notice params" do
    it "corrected" do
      yearly_manifest = Generators::Reports::IrsYearlyManifest.new
      yearly_manifest.notice_params = {type: 'corrected'}
      expect(yearly_manifest.notice_params).to eq({type: 'corrected'})
    end

    it "void" do
      yearly_manifest = Generators::Reports::IrsYearlyManifest.new
      yearly_manifest.notice_params = {type: 'void'}
      expect(yearly_manifest.notice_params).to eq({type: 'void'})
    end

    it 'something else (new)' do
      yearly_manifest = Generators::Reports::IrsYearlyManifest.new
      yearly_manifest.notice_params = {type: 'new'}
      expect(yearly_manifest.notice_params).to eq({type: 'new'})
    end
  end
end
