require "rails_helper"
require File.join(Rails.root,"app","data_migrations","conversions.rb")

describe ChangeSsn, dbclean: :after_each do
  let(:given_task_name) { "conversions.rb" }
  let(:policy) { FactoryGirl.create(:policy) }
  subject { GenerateTransforms.new }


  describe "converting a policy to a CV2.1" do
    before(:each) do 
      allow(ENV).to receive(:[]).with("eg_ids").and_return(policy.id)
      allow(ENV).to receive(:[]).with("reason_code").and_return("reinstate_enrollment")
    end

    it "can convert the policy to a CV2.1" do 





    end 
  end
end