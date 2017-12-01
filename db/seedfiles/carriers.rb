if  !Rails.env.development?
  CARRIERS = YAML.load_file(Rails.root.join('db', 'seedfiles', 'carriers.yml'))
  puts "Loading: Carriers"

  #Carrier.collection.drop
  CARRIERS.each { |c| Carrier.create!(c) }

  puts "Load complete: Carriers"
else
  FactoryGirl.create(:health_and_dental_carrier)
  FactoryGirl.create(:health_carrier)
  FactoryGirl.create(:dental_carrier)
  FactoryGirl.create(:shop_health_carrier)
  FactoryGirl.create(:shop_dental_carrier)
  FactoryGirl.create(:shop_health_and_dental_carrier)
  FactoryGirl.create(:ivl_health_carrier)
  FactoryGirl.create(:ivl_dental_carrier)
  FactoryGirl.create(:ivl_health_and_dental_carrier)
end
