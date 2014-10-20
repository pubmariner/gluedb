EventRoute.delete_all

EventRoute.create!({
  :exchange_name => "dc0.events.topic.individual",
  :exchange_kind => "topic",
  :routing_key => "qhp_selected",
  :event_uri => "urn:openhbx:events:v1:individual#qhp_selected"
})

EventRoute.create!({
  :exchange_name => "dc0.events.topic.employer_employee",
  :exchange_kind => "topic",
  :routing_key => "qhp_selected",
  :event_uri => "urn:openhbx:events:v1:employers_employees#qhp_selected"
})
