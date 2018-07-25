FactoryGirl.define do
  factory :policy do
    sequence(:eg_id) { |n| "#{n}" }
    pre_amt_tot '666.66'
    tot_res_amt '111.11'
    tot_emp_res_amt '222.22'
    carrier_to_bill true
    allocated_aptc '0.00'
    elected_aptc '0.00'
    applied_aptc '0.00'
    broker
    plan
    carrier_specific_plan_id 'rspec-mock'
    rating_area  "100"
    composite_rating_tier 'rspec-mock'
    kind 'individual'
    enrollment_kind 'open_enrollment'

    after(:create) do |p, evaluator|
      create_list(:enrollee, 2, policy: p)
    end
 

    trait :shop do
      employer
      kind 'employer_sponsored'
      after(:create) do |policy|
        create :premium_payment, employer: policy.employer, carrier: policy.plan.carrier, policy: policy
      end
    end

    trait :terminated do
      aasm_state "terminated"
    end

    trait :sep do
      enrollment_kind 'special_enrollment'
    end
    trait :ivl_health do
      employer_id nil
      association :plan, factory: :ivl_health_plan
    end

    trait :with_aptc do
      allocated_aptc '3.33'
      elected_aptc '3.33'
      applied_aptc '3.33'
    end

    trait :with_csr do
      association :plan, factory: :ivl_assisted_plan
    end

    trait :canceled_dependent do 
      after(:create) do |p, evaluator|
        create_list(:enrollee, 2, policy: p)
        create_list(:cancelled_enrollee,1, policy: p)
      end
    end

    factory :shop_policy, traits: [:shop]
    factory :terminated_policy, traits: [:terminated]
    factory :ivl_health_policy, traits: [:ivl_health]
    factory :ivl_assisted_health_policy_with_aptc_and_csr, traits: [:ivl_health, :with_aptc, :with_csr]
    factory :ivl_assisted_health_policy_with_aptc_no_csr, traits: [:ivl_health, :with_aptc]
    factory :ivl_assisted_health_policy_no_aptc_with_csr, traits: [:with_csr]
    factory :canceled_dependent_policy, traits: [:canceled_dependent]
  end
end
