active_pols = Policy.where(Policy.active_as_of_expression(Date.new(2014, 12, 31)).merge({"employer_id" => nil}))

all_subscribers = (active_pols.map do |pol|
    pol.subscriber.person.id
end).uniq

all_subscribers.each do |sub|
  count = ApplicationGroup.where(
    :people_ids => { "$in" => all_subscribers }   
  )
  puts count.count.to_s
end
