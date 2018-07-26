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

  context 'merge two policies happy path' do 

    before(:each) do 
      ENV['policy_to_keep'] = policy_to_keep.eg_id
      ENV['policy_to_remove'] = policy_to_remove.eg_id
      ENV['policy_of_final_tot_res_amt'] = policy_to_remove.eg_id
      ENV['policy_of_final_pre_amt_tot'] = policy_to_remove.eg_id
      ENV['policy_of_final_tot_emp_res_amt'] = policy_to_remove.eg_id
      ENV['policy_of_final_rating_area'] = policy_to_remove.eg_id
      ENV['policy_of_final_composite_rating_tier'] = policy_to_remove.eg_id
    end
    
    it 'should merge two policies' do

      subject.migrate
      policy_to_keep.reload
      policy_to_remove.reload
      
      expect(policy_to_keep.tot_res_amt).to eq 300
      expect(policy_to_keep.pre_amt_tot).to eq 400
      expect(policy_to_keep.tot_emp_res_amt).to eq 500
      expect(policy_to_keep.rating_area).to eq "A050"
      expect(policy_to_keep.composite_rating_tier).to eq "2"
      expect(policy_to_keep.enrollees.map(&:m_id)).to eq ['1','2','3','4']
      expect(policy_to_keep.hbx_enrollment_ids).to eq ['1','2']
      expect(policy_to_remove.hbx_enrollment_ids).to eq ["2 - DO NOT USE"]
      expect(policy_to_remove.eg_id).to eq "2 - DO NOT USE"

    end
  end

  context 'merge two policies sad path' do 
    
    it 'should error if there are missing policy inputs' do
      ENV['policy_to_remove'] = ""     
      
      subject.migrate
      policy_to_keep.reload
      
      expect(subject.migrate).to eq "You are missing a policy for input please check your rake again"

    end

    it 'should error if it cannot find the policy' do
      ENV['policy_to_remove'] = "10"

      subject.migrate
      policy_to_keep.reload
      
      expect(subject.migrate).to eq  'We cannot find a policy with that id'

    end
  end
end

describe MergeTwoPolicies, dbclean: :before_each do
  DatabaseCleaner.clean

  let(:given_task_name) { "merge_two_policies" }
  let(:policy_to_keep) { FactoryGirl.create(:policy) }
  let(:policy_to_keep_enrollees){ policy_to_keep.enrollees  }
  let(:policy_to_remove) { FactoryGirl.create(:policy, tot_res_amt:300, pre_amt_tot:400,tot_emp_res_amt:500,rating_area:"D050", composite_rating_tier:"100") }
  let(:policy_to_remove_enrollees){policy_to_remove.enrollees }

  subject { MergeTwoPolicies.new(given_task_name, double(:current_scope => nil)) }
  
  context 'merging two policies together using a mix of policies attributes to keep' do 

    before(:each) do 
      ENV['policy_to_keep'] = policy_to_keep.eg_id
      ENV['policy_to_remove'] = policy_to_remove.eg_id
      ENV['policy_of_final_tot_res_amt'] = policy_to_keep.eg_id
      ENV['policy_of_final_pre_amt_tot'] = policy_to_keep.eg_id
      ENV['policy_of_final_tot_emp_res_amt'] = policy_to_remove.eg_id
      ENV['policy_of_final_rating_area'] = policy_to_remove.eg_id
      ENV['policy_of_final_composite_rating_tier'] = policy_to_remove.eg_id

    end

    it 'should merge another two policies together ' do

      subject.migrate
      policy_to_keep.reload
      policy_to_remove.reload
      

      expect(policy_to_keep.tot_res_amt).to eq 111.11.to_d
      expect(policy_to_keep.pre_amt_tot).to eq 666.66.to_d
      expect(policy_to_keep.tot_emp_res_amt).to eq 500.to_d
      expect(policy_to_keep.rating_area).to eq "D050"
      expect(policy_to_keep.composite_rating_tier).to eq "100"
      expect(policy_to_keep.hbx_enrollment_ids).to eq ['5','6']
      expect(policy_to_remove.hbx_enrollment_ids).to eq ["6 - DO NOT USE"]
      expect(policy_to_remove.eg_id).to eq "6 - DO NOT USE"
    end
    
  end
end





