module Parsers
  module Edi
    class PersonLoopValidator
      def validate(person_loop, listener)
        carrier_member_id = person_loop.carrier_member_id
        if(carrier_member_id.blank?)
          listener.missing_carrier_member_id(person_loop)
          false
        else
          listener.found_carrier_member_id(carrier_member_id)
          true
        end
      end
    end
  end
end
