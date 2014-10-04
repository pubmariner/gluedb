active_pols = Policy.where(Policy.active_as_of_expression(Date.new(2014, 12, 31)).merge({"employer_id" => nil}))

active_pols.map do |pol|
  subscriber_person = pol.subscriber.person.id
  ags = ApplicationGroup.where(
    :people_ids => { "$in" => [subscriber_person] }
  )
  if ags.count == 1
    pol.application_group = ags.first
    pol.save!
  end
end
