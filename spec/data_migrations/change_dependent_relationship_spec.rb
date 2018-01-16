require "rails_helper"
require File.join(Rails.root,"app","data_migrations","change_dependent_relationship")

describe ChangeDependentRelationship, dbclean: :after_each do
  let(:given_task_name) { "change_dependent_relationship" }
  let(:policy) { FactoryGirl.create(:policy) }
  let (:enrollee) { policy.enrollees.last }
  subject { ChangeDependentRelationship.new(given_task_name, double(:current_scope => nil)) }

  describe "given a task name" do
    it "has the given task name" do
      expect(subject.name).to eq given_task_name
    end
  end

  describe "changing the relationship of an enroll in a  policy" do
    before(:each) do
      allow(ENV).to receive(:[]).with("eg_id").and_return(policy.eg_id)
      allow(ENV).to receive(:[]).with("hbx_member_id").and_return(enrollee.m_id)
      allow(ENV).to receive(:[]).with("new_relationship_type").and_return('ward')
    end
    it "should alter relationship of the enrollee " do
      subject.migrate
      relationship_type = enrollee.rel_code
      policy.reload
      enrollee.reload
      expect(enrollee.rel_code).not_to eq relationship_type
      expect(enrollee.rel_code).to eq 'ward'
    end
  end

  describe "not change relationship if no policy found" do
    before(:each) do
      allow(ENV).to receive(:[]).with("eg_id").and_return("")
      allow(ENV).to receive(:[]).with("hbx_member_id").and_return(enrollee.m_id)
      allow(ENV).to receive(:[]).with("new_relationship_type").and_return('ward')
    end
    it "should not alter relationship if no policy found" do
      subject.migrate
      relationship_type = enrollee.rel_code
      policy.reload
      enrollee.reload
      expect(enrollee.rel_code).to eq relationship_type
      expect(enrollee.rel_code).not_to eq 'ward'
    end
  end

  describe "not change relationship if no enrollee was found" do
    before(:each) do
      allow(ENV).to receive(:[]).with("eg_id").and_return(policy.eg_id)
      allow(ENV).to receive(:[]).with("hbx_member_id").and_return("")
      allow(ENV).to receive(:[]).with("new_relationship_type").and_return('ward')
    end
    it "should not alter relationship if no policy found" do
      subject.migrate
      relationship_type = enrollee.rel_code
      policy.reload
      enrollee.reload
      expect(enrollee.rel_code).to eq relationship_type
      expect(enrollee.rel_code).not_to eq 'ward'
    end
  end

  describe "not change relationship if relationship type is not valid" do
    before(:each) do
      allow(ENV).to receive(:[]).with("eg_id").and_return(policy.eg_id)
      allow(ENV).to receive(:[]).with("hbx_member_id").and_return(enrollee.m_id)
      allow(ENV).to receive(:[]).with("new_relationship_type").and_return('not_valid_type')
    end
    it "should not alter relationship if no policy found" do
      subject.migrate
      relationship_type = enrollee.rel_code
      policy.reload
      enrollee.reload
      expect(enrollee.rel_code).to eq relationship_type
      expect(enrollee.rel_code).not_to eq 'not_valid_type'
    end
  end
end