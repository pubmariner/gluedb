FactoryGirl.define do 
  factory :premium_table do 
    sequence(:age) { |n| 17 + n }
    rate_start_date Date.today.beginning_of_year
    rate_end_date Date.today.end_of_year

    trait :health do 
      sequence(:amount) { |n| 215.to_d + n.to_d } 
    end

    trait :dental do 
      sequence(:amount) { |n| 25.to_d + n.to_d }
    end

    trait :renewal do 
      rate_start_date Date.today.beginning_of_year + 1.year
      rate_end_date Date.today.end_of_year + 1.year
    end

    factory :health_premium_table, traits: [:health]
    factory :dental_premium_table, traits: [:dental]
  end
end