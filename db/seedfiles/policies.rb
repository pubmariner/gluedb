puts "Loading: Policies"

unless Rails.env.development?
  POLCIES = YAML.load_file(Rails.root.join('db', 'seedfiles', 'policies.yml'))
  puts "Loading: Policies"

  #Policy.collection.drop
  POLICIES.each { |p| Policy.create!(p) }

  puts "Load complete: Policies"
else
  FactoryGirl.create(:shop_policy)
  FactoryGirl.create(:terminated_policy)
  FactoryGirl.create(:ivl_health_policy)
  FactoryGirl.create(:ivl_assisted_health_policy_with_aptc_and_csr)
  FactoryGirl.create(:ivl_assisted_health_policy_with_aptc_no_csr)
  FactoryGirl.create(:ivl_assisted_health_policy_no_aptc_with_csr)
end