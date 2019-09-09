module Listeners
  class PolicyUpdatedObserver < ::Amqp::Client

    def self.notify(policy)
      if policy.present?
        year_range = [Date.today.prev_year.year]
        if policy.market == "individual" && policy.plan.coverage_type == "health" && policy.plan.year.in?(year_range)
          broadcast(policy)
        end
      end
    end

    def self.broadcast(policy)
      conn = AmqpConnectionProvider.start_connection
      eb = Amqp::EventBroadcaster.new(conn)
      eb.broadcast(
      {
        :routing_key => "info.events.policy.federal_reporting_eligiblity_updated",
        :headers => {
          policy_object_id: policy.id,
          enrollment_group_id: policy.eg_id
        }
      },
      ""
    )
    end 
  end 
end
