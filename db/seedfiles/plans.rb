require 'csv'

puts "Loading: Plans"

if !Rails.env.development? || Rails.env.test?
  # Plan.collection.drop

  csv_loc = File.join(File.dirname(__FILE__), "plans.csv")

  carrier_hash = Hash.new do |h, k|
    h[k] = Carrier.where(:hbx_carrier_id => k).first
  end

  plans = []

  CSV.foreach(File.open(csv_loc), headers: true) do |row|
    record = row.to_hash.dup
    carrier_h_id = record.delete("carrier_hbx_id")
    record["carrier_id"] = carrier_hash[carrier_h_id]._id
    plans << record
  end

  Plan.create!(plans)

end
