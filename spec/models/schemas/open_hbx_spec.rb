require "spec_helper"

describe Schemas::OpenHbx do

  it "should contain a schema" do
    expect(Schemas::OpenHbx.get).not_to be_nil
  end
end
