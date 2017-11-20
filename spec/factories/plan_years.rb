FactoryGirl.define do
  factory :plan_year do
    start_date Date.today.beginning_of_month  
    end_date Date.today.beginning_of_month + 1.year - 1.day
    open_enrollment_start Date.today.beginning_of_month - 2.months
    open_enrollment_end Date.today.beginning_of_month - 1.month + 9.days
    fte_count  1
    pte_count  1
  end

  trait :renewal_year do 
    start_date Date.today.beginning_of_month + 1.year  
    end_date Date.today.beginning_of_month + 2.year - 1.day
    open_enrollment_start Date.today.beginning_of_month + 1.year - 2.months
    open_enrollment_end  Date.today.beginning_of_month + 1.year - 1.month + 9.days
  end

  trait :with_broker do
    after(:create) do |plan_year|
      create :broker, plan_year: plan_year
    end
  end

  factory :renewal_plan_year, traits: [:renewal_year]
end