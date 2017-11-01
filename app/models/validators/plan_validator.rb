module Validators

  class PlanValidator
    def initialize(change_request, plan, listener)
      @change_request = change_request
      @plan = plan
      @listener = listener
    end

    def validate
      valid = true
      if @plan.blank?
        @listener.plan_not_found
        valid = false
      end
      return valid
    end
  end
end
