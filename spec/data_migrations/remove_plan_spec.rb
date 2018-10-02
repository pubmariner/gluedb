require "rails_helper"
require File.join(Rails.root,"app","data_migrations", "remove_plan")

describe RemovePlan, dbclean: :after_each do
  let(:given_task_name) { "remove_plan" }
  let(:plan) { FactoryGirl.create(:plan)}
  subject { RemovePlan.new(given_task_name, double(:current_scope => nil))}

  describe "given a task name" do 
    it "has the given task name" do 
      expect(subject.name).to eql given_task_name
    end
  end

  describe "removing a plan" do 

    before(:each) do 
      allow(ENV).to receive(:[]).with("hios_plan_id").and_return(plan.hios_plan_id)
    end

    it 'should change the end date' do
      expect(Plan.count).to eq 1
      subject.migrate
      expect(Plan.count).to eq 0
    end
    
  end
end