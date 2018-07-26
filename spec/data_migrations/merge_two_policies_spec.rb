require 'pry'
require "rails_helper"
require File.join(Rails.root,"app","data_migrations","merge_two_policies")

describe MergeTwoPolicies, dbclean: :after_each do
  let(:given_task_name) { "merge_two_policies" }
  let(:policy_to_keep) { FactoryGirl.create(:policy) }
  let(:policy_to_keep_enrollees){ policy_to_keep.enrollees  }
  let(:policy_to_remove) { FactoryGirl.create(:policy, tot_res_amt:300, pre_amt_tot:400,tot_emp_res_amt:500,rating_area:"A050", composite_rating_tier:"2") }
  let(:policy_to_remove_enrollees){policy_to_remove.enrollees }

  subject { MergeTwoPolicies.new(given_task_name, double(:current_scope => nil)) }

  describe "given a task name" do 
    it "has the given task name" do 
      expect(subject.name).to eql given_task_name
    end
  end

  describe 'merge the policies' do 

    before(:each) do 
      
      # allow(ENV).to receive(:[]).with("policy_to_keep").and_return(policy_to_keep.eg_id)
      # allow(ENV).to receive(:[]).with("policy_to_remove").and_return(policy_to_remove.eg_id)
      # allow(ENV).to receive(:[]).with("policy_of_final_tot_res_amt").and_return(policy_to_remove.eg_id)
      # allow(ENV).to receive(:[]).with("policy_of_final_pre_amt_tot").and_return(policy_to_remove.eg_id)
      # allow(ENV).to receive(:[]).with("policy_of_final_tot_emp_res_amt").and_return(policy_to_remove.eg_id)
      # allow(ENV).to receive(:[]).with("policy_of_final_rating_area").and_return(policy_to_remove.eg_id)
      # allow(ENV).to receive(:[]).with("policy_of_final_composite_rating_tier").and_return(policy_to_remove.eg_id)
    end
    
    it 'should merge two policies' do
      ENV['policy_to_keep'] = policy_to_keep.eg_id
      ENV['policy_to_remove'] = policy_to_remove.eg_id
      ENV['policy_of_final_tot_res_amt'] = policy_to_remove.eg_id
      ENV['policy_of_final_pre_amt_tot'] = policy_to_remove.eg_id
      ENV['policy_of_final_tot_emp_res_amt'] = policy_to_remove.eg_id
      ENV['policy_of_final_rating_area'] = policy_to_remove.eg_id
      ENV['policy_of_final_composite_rating_tier'] = policy_to_remove.eg_id
      subject.migrate
      policy_to_keep.reload
      
      expect(policy_to_keep.tot_res_amt).to eq 300
      expect(policy_to_keep.pre_amt_tot).to eq 400
      expect(policy_to_keep.tot_emp_res_amt).to eq 500
      expect(policy_to_keep.rating_area).to eq "A050"
      expect(policy_to_keep.composite_rating_tier).to eq "2"
      expect(policy_to_keep.enrollees.map(&:m_id)).to eq ['1','2','3','4']
      expect(policy_to_keep.hbx_enrollment_ids).to eq ['1','2']
      expect(policy_to_remove.hbx_enrollment_ids).to eq ['2']

    end

  end
end