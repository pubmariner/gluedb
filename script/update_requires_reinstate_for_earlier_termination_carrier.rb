 Carrier.all.each do |carrier|
   unless carrier.name == "Care First"
     carrier.update_attributes(requires_reinstate_for_earlier_termination: true)
   end
 end
