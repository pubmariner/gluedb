year = '2017'

puts "Importing #{year} plans"
plan_file = File.open("db/seedfiles/#{year}_plans.json", "r")
data = plan_file.read
plan_file.close
plan_data = JSON.load(data)
puts "Before: total #{Plan.count} plans"
puts "#{plan_data.size} plans in json file"
plan_data.each do |pd|
  plan = Plan.new(pd)
  plan.id = pd["id"]
  plan.save!
end
puts "After: total #{Plan.count} plans"
puts "Finished importing #{year} plans"