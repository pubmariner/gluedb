FactoryGirl.define do
  factory :member do
    sequence(:hbx_member_id) {|n| "#{n}" }
    gender 'female'
    sequence(:ssn, 100000000) { |n| "#{n}" }
    dob Date.today - 27.years

    trait :adult_under_26 do 
      dob Date.today - 23.years
    end

    trait :child do 
      dob Date.today - 17.years
    end

    factory :adult_member_under_26, traits: [:adult_under_26]
    factory :child_member, traits: [:child]
  end
end