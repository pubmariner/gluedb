FactoryGirl.define do
  factory :carrier do
    name 'Super Awesome Carrier'
    sequence(:hbx_carrier_id) { |n| "#{n}" }

    trait :health_and_dental do 
      name 'Health and Dental Carrier'
      abbrev 'HDC'
      ind_hlt true
      ind_dtl true
      shp_hlt true
      shp_dtl true

      after(:create) do |carrier, evaluator|
        create_list(:ivl_health_plan, 1, carrier: carrier)
        create_list(:ivl_dental_plan, 1, carrier: carrier)
        create_list(:ivl_assisted_plan, 1, carrier: carrier)
        create_list(:shop_health_plan, 1, carrier: carrier)
        create_list(:shop_dental_plan, 1, carrier: carrier)
      end
    end

    trait :health_only do
      name 'Health Carrier'
      abbrev 'DCHC'
      ind_hlt true
      shp_hlt true

      after(:create) do |carrier, evaluator|
        create_list(:ivl_health_plan, 1, carrier: carrier)
        create_list(:ivl_assisted_plan, 1, carrier: carrier)
        create_list(:shop_health_plan, 1, carrier: carrier)
      end
    end

    trait :dental_only do 
      name 'Dental Carrier'
      abbrev 'DCDC'
      ind_dtl true
      shp_dtl true

      after(:create) do |carrier, evaluator|
        create_list(:ivl_dental_plan, 1, carrier: carrier)
        create_list(:shop_dental_plan, 1, carrier: carrier)
      end
    end

    trait :shop_health do 
      name 'SHOP Health Carrier'
      abbrev 'SHC'
      shp_hlt true

      after(:create) do |carrier, evaluator|
        create_list(:shop_health_plan, 1, carrier: carrier)
      end
    end

    trait :shop_dental do 
      name 'SHOP Dental Carrier'
      abbrev 'SDC'
      shp_dtl true

      after(:create) do |carrier, evaluator|
        create_list(:shop_dental_plan, 1, carrier: carrier)
      end
    end

    trait :shop_health_and_dental do 
      name 'SHOP Health and Dental Carrier'
      abbrev 'SHDC'
      shp_hlt true
      shp_dtl true

      after(:create) do |carrier, evaluator|
        create_list(:shop_health_plan, 1, carrier: carrier)
        create_list(:shop_dental_plan, 1, carrier: carrier)
      end
    end

    trait :ivl_health do 
      name 'IVL Health Carrier'
      abbrev 'IHC'
      ind_hlt true

      after(:create) do |carrier, evaluator|
        create_list(:ivl_health_plan, 1, carrier: carrier)
        create_list(:ivl_assisted_plan, 1, carrier: carrier)
      end
    end

    trait :ivl_dental do 
      name 'IVL Dental Carrier'
      abbrev 'IDC'
      ind_dtl true

      after(:create) do |carrier, evaluator|
        create_list(:ivl_dental_plan, 1, carrier: carrier)
      end
    end

    trait :ivl_health_and_dental do 
      name 'IVL Health and Dental Carrier'
      abbrev 'IHDC'
      ind_hlt true
      ind_dtl true

      after(:create) do |carrier, evaluator|
        create_list(:ivl_health_plan, 1, carrier: carrier)
        create_list(:ivl_dental_plan, 1, carrier: carrier)
        create_list(:ivl_assisted_plan, 1, carrier: carrier)
      end
    end

    factory :health_and_dental_carrier, traits: [:health_and_dental]
    factory :health_carrier, traits: [:health_only]
    factory :dental_carrier, traits: [:dental_only]
    factory :shop_health_carrier, traits: [:shop_health]
    factory :shop_dental_carrier, traits: [:shop_dental]
    factory :shop_health_and_dental_carrier, traits: [:shop_health_and_dental]
    factory :ivl_health_carrier, traits: [:ivl_health]
    factory :ivl_dental_carrier, traits: [:ivl_dental]
    factory :ivl_health_and_dental_carrier, traits: [:ivl_health_and_dental]
  end
end
