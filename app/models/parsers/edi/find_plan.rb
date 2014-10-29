module Parsers
  module Edi
    class FindPlan
      def initialize(listener)
        @listener = listener
      end

      def by_hios_id(hios_id)
        plan = Plan.find_by_hios_id(hios_id)
        if(plan)
          @listener.plan_found(plan)
          plan
        else
          @listener.plan_not_found(hios_id)
          nil
        end
      end
    end
  end
end
