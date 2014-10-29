module Parsers
  module Edi
    class IncomingTransaction
      attr_reader :errors

      def self.from_etf(etf, i_cache)
        incoming_transaction = new(etf)

        find_carrier = FindCarrier.new(incoming_transaction, i_cache)
        carrier = find_carrier.by_fein(etf.carrier_fein)

        subscriber_policy_loop = etf.subscriber_loop.policy_loops.first
        find_plan = FindPlan.new(incoming_transaction)

        plan_year = nil

        coverage_start = Date.parse(subscriber_policy_loop.coverage_start)
        if(etf.is_shop?)
          employer_loop = Etf::EmployerLoop.new(etf.employer_loop)
          employer = Employer.find_for_fein(employer_loop.fein)

          plan_year = PlanYear.where({
            :employer_id => employer.id,
            :start_date => { "$lte" => coverage_start }
          }).order_by(&:start_date).last.year
        else
          plan_year = Date.parse(subscriber_policy_loop.coverage_start).year
        end

        plan = find_plan.by_hios_id_and_year(subscriber_policy_loop.hios_id, plan_year)

        if(carrier && plan)
          find_policy = FindPolicy.new(incoming_transaction)
          policy = find_policy.by_subkeys({
            :eg_id => subscriber_policy_loop.eg_id,
            :carrier_id => carrier._id,
            :hios_plan_id => subscriber_policy_loop.hios_id
          })
        end

        person_loop_validator = PersonLoopValidator.new
        etf.people.each do |person_loop|
          person_loop_validator.validate(person_loop, incoming_transaction)
        end

        policy_loop_validator = PolicyLoopValidator.new
        policy_loop_validator.validate(subscriber_policy_loop, incoming_transaction)

        incoming_transaction
      end

      def initialize(etf)
        @etf = etf
        @errors = []
      end

      def valid?
        @errors.empty?
      end

      def import
        return unless valid?
        @etf.people.each do |person_loop|
          enrollee = @policy.enrollee_for_member_id(person_loop.member_id)

          policy_loop = person_loop.policy_loops.first

          enrollee.c_id = person_loop.carrier_member_id
          enrollee.cp_id = policy_loop.id

          if(!@etf.is_shop? && policy_loop.action == :stop )
            enrollee.coverage_status = 'inactive'
            enrollee.coverage_end = policy_loop.coverage_end

            if enrollee.subscriber?
              if enrollee.coverage_start == enrollee.coverage_end
                enrollee.policy.aasm_state = "canceled"
              else
                enrollee.policy.aasm_state = "terminated"
              end
            end

          end
        end
        @policy.save
      end

      def policy_found(policy)
        @policy = policy
      end

      def policy_not_found(subkeys)
        @errors << "Policy not found. Details: #{subkeys}"
      end

      def plan_found(plan)
        @plan = plan
      end

      def plan_not_found(hios_id)
        @errors << "Plan not found. (hios id: #{hios_id})"
      end

      def carrier_found(carrier)
        @carrier = carrier
      end

      def carrier_not_found(fein)
        @errors << "Carrier not found. (fein: #{fein})"
      end

      def found_carrier_member_id(id)
      end

      def missing_carrier_member_id(person_loop)
        policy_loop = person_loop.policy_loops.first
        if(!policy_loop.canceled?)
          @errors << "Missing Carrier Member ID."
        end
      end

      def found_carrier_policy_id(id)
      end

      def missing_carrier_policy_id
        @errors << "Missing Carrier Policy ID."
      end

      def policy_id
        @policy ? @policy._id : nil
      end

      def carrier_id
        @carrier ? @carrier._id : nil
      end

      def employer_id
        @employer ? @employer._id : nil
      end
    end
  end
end
