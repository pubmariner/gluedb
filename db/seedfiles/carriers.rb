unless Rails.env.development?
  CARRIERS = YAML.load_file(Rails.root.join('db', 'seedfiles', 'carriers.yml'))
  puts "Loading: Carriers"

  #Carrier.collection.drop
  CARRIERS.each { |c| Carrier.create!(c) }

  puts "Load complete: Carriers"
else

end
