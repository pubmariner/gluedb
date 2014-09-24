Policy.process_audits(
Date.new(2013, 10, 1),
Date.new(2014, 8, 31),
Date.new(2013, 10, 1),
Date.new(2014, 8, 31),
{:carrier_id => Carrier.where(:abbrev => "UHIC").first.id},
"audits"
)
