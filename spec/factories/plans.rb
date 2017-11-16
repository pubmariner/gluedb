FactoryGirl.define do
  factory :plan do
    name 'Super Plan A'
    abbrev 'SPA'
    hbx_plan_id '1234'
    hios_plan_id '4321'
    coverage_type 'health'
    metal_level 'bronze'
    market_type 'individual'
    year Date.today.year
    ehb 0.0
    carrier

    trait :shop_health do
      name 'SHOP Health Plan'
      abbrev 'SHPB'
      hbx_plan_id '7472'
      hios_plan_id '2747'
      market_type 'shop'
      carrier
    end

    trait :shop_dental do 
      name 'SHOP Dental Plan'
      abbrev 'SHDP'
      hbx_plan_id '7437'
      hios_plan_id '7347'
      market_type 'shop'
      metal_level 'dental'
      coverage_type 'dental'
      carrier
    end

    trait :ivl_assisted do 
      name 'IVL Assisted Plan'
      abbrev 'IVAP'
      hbx_plan_id '4827'
      hios_plan_id '7284'
      metal_level 'silver'
      carrier
    end

    trait :ivl_dental do 
      name 'IVL Dental Plan'
      abbrev 'IVDP'
      hbx_plan_id '4837'
      hios_plan_id '7384'
      metal_level 'dental'
      coverage_type 'dental'
      carrier
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
        end
    end

    factory :shop_health_plan, traits: [:shop_health]
    factory :shop_dental_plan, traits: [:shop_dental]
    factory :ivl_assisted_plan, traits: [:ivl_assisted]
    factory :ivl_dental_plan, traits: [:ivl_dental]
    factory :renewal_plans, traits: [:renewal_plan]
  end
end
