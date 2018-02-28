FactoryGirl.define do
  factory :enrollee do
    m_id {FactoryGirl.create(:person).authority_member_id}
    ben_stat 'active'
    emp_stat 'active'
    rel_code 'self'
    ds false
    pre_amt '666.66'
    sequence(:c_id) { |n| "#{n}" }
    sequence(:cp_id) { |n| "#{n}" }
    coverage_start Date.new(2014,1,2)
    coverage_end Date.new(2014,3,4)
    coverage_status 'active'

    trait :self_relationship do
      rel_code 'self'
    end

    factory :subscriber_enrollee, traits: [:self_relationship]
  end
end