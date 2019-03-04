carrier = Carrier.all.where(name:'Care First').first
carrier.update_attributes(requires_reinstate_for_earlier_termination: true)
