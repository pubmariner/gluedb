require "rails_helper"

RSpec.describe "edi_transaction_sets/show.html.erb" do
  include Devise::TestHelpers
  let(:edi_transaction_set) do 
    double(
      id: 1,
      st01: "1",
      st02: "2",
      st03: "3",
      bgn01: "1",
      bgn02: "2",
      bgn03: "3",
      bgn04: "4",
      bgn05: "5",
      bgn06: "6",
      bgn08: "8",
      transaction_kind: "fake_transaction",
      submitted_at: Date.today.to_s
    )
  end

  before(:each) do
    assign(:edi_transaction_set, edi_transaction_set)
  end

  it "should render the proper page elements" do 
    render :template => "edi_transaction_sets/show"
  end
end