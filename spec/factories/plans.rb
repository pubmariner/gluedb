FactoryGirl.define do
  factory :plan do
    name 'Super Plan A'
    abbrev 'SPA'
    sequence(:hbx_plan_id, 1234) {|n| "#{n}" }
    sequence(:hios_plan_id, 4321) {|n| "#{n}" }
    coverage_type 'health'
    metal_level 'bronze'
    market_type 'individual'
    year Date.today.year
    ehb 0.0
    carrier

    trait :ivl_health do
      name 'IVL Health Plan'
      association :carrier, factory: :ivl_health_carrier
      after(:create) do |plan,evaluator|
        create_list(:health_premium_table, 120, plan: plan)
      end
    end

    trait :shop_health do
      name 'SHOP Health Plan'
      abbrev 'SHPB'
      sequence(:hbx_plan_id, 12345) {|n| "#{n}" }
      sequence(:hios_plan_id, 54321) {|n| "#{n}" }
      market_type 'shop'
      association :carrier, factory: :ivl_health_carrier

      after(:create) do |plan,evaluator|
        create_list(:health_premium_table, 120, plan: plan)
      end
    end

    trait :shop_dental do
      name 'SHOP Dental Plan'
      abbrev 'SHDP'
      sequence(:hbx_plan_id, 123456) {|n| "#{n}" }
      sequence(:hios_plan_id, 654321) {|n| "#{n}" }
      market_type 'shop'
      metal_level 'dental'
      coverage_type 'dental'
      carrier

      after(:create) do |plan,evaluator|
        create_list(:dental_premium_table, 120, plan: plan)
      end
    end

    trait :ivl_assisted do
      name 'IVL Assisted Plan'
      abbrev 'IVAP'
      sequence(:hbx_plan_id, 1234567) {|n| "#{n}" }
      sequence(:hios_plan_id, 7654321) {|n| "#{n}" }
      metal_level 'silver'
      carrier

      after(:create) do |plan,evaluator|
        create_list(:health_premium_table, 120, plan: plan)
      end
    end

    trait :ivl_dental do
      name 'IVL Dental Plan'
      abbrev 'IVDP'
      sequence(:hbx_plan_id, 12345678) {|n| "#{n}" }
      sequence(:hios_plan_id, 87654321) {|n| "#{n}" }
      metal_level 'dental'
      coverage_type 'dental'
      carrier

      after(:create) do |plan,evaluator|
        create_list(:dental_premium_table, 120, plan: plan)
      end
    end

    trait :renewal_plan do
        Plan.where(year: Date.today.year).each do |plan|
          renewal_plan = plan.clone
          renewal_plan.carrier = plan.carrier
          renewal_plan.year = (Date.today + 1.year).year
          renewal_plan.hios_plan_id = (plan.hios_plan_id.to_i + 1).to_s
          renewal_plan.hbx_plan_id = (plan.hbx_plan_id.to_i + 1).to_s
          renewal_plan.save
          plan.renewal_plan = renewal_plan
          plan.save
          plan.premium_tables.each do |pt|
            pt.rate_start_date += 1.year
            pt.rate_end_date += 1.year
            pt.save
          end
        end
    end

    factory :ivl_health_plan, traits: [:ivl_health]
    factory :shop_health_plan, traits: [:shop_health]
    factory :shop_dental_plan, traits: [:shop_dental]
    factory :ivl_assisted_plan, traits: [:ivl_assisted]
    factory :ivl_dental_plan, traits: [:ivl_dental]
    factory :renewal_plans, traits: [:renewal_plan]
  end
end
