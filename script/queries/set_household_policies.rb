Policy.collection.where.update_all({"$set" => {"application_group_id" => nil}})
active_pols = Policy.where(Policy.active_as_of_expression(Date.new(2014, 12, 31)).merge({"employer_id" => nil}))

no_match = 0
too_many_matched = 0
active_pols.map do |pol|
  subscriber_person = pol.subscriber.person.id
  ags = ApplicationGroup.where(
    :person_ids => { "$in" => [subscriber_person] }
  )
  case ags.count
  when 1
    pol.application_group = ags.first
    pol.save!
  when 0
    no_match = no_match + 1
  else
    too_many_matched = too_many_matched + 1
  end
end

puts "No match: #{no_match}"
puts "Too many matched: #{too_many_matched}"
