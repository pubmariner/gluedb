EventRoute.delete_all

EventRoute.create!({
  :exchange_name => "dc0.uat.e.topic.events",
  :exchange_kind => "topic",
  :routing_key => "individual.qhp_selected",
  :event_uri => "urn:openhbx:events:v1:individual#qhp_selected"
})

EventRoute.create!({
  :exchange_name => "dc0.uat.e.topic.events",
  :exchange_kind => "topic",
  :routing_key => "employer_employee.qhp_selected",
  :event_uri => "urn:openhbx:events:v1:employers_employees#qhp_selected"
})
