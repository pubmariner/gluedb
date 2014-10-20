require 'spec_helper'

describe DocumentValidator do
  let(:document) { double }
  subject { DocumentValidator.new(document, schema) }

  describe "Given an invalid document" do
    let(:schema) {
      s = double
      allow(s).to receive(:validate).with(document) { ["whatever"] }
      s
    }

    it { should_not be_valid }
    it "should have the right errors" do
      expect(subject).not_to be_valid
      expect(subject.errors.full_messages).to include("Document whatever") 
    end
  end

  describe "Given a valid document" do
    let(:schema) {
      s = double
      allow(s).to receive(:validate).with(document) { [] }
      s
    }

    it { should be_valid }
  end
end
