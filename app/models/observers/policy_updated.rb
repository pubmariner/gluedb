module Observers
  class PolicyUpdated

    def self.notify(policy, time = Time.now)
      notify_of_federal_reporting_changes(policy, time)
    end

    def self.notify_of_federal_reporting_changes(policy, time)
      return if policy.is_shop?
      return if policy.coverage_type.to_s.downcase != "health"
      return if policy.coverage_year == time.year
      return if policy.coverage_year < 2018
      ::Amqp::EventBroadcaster.with_broadcaster do |b|
        b.broadcast(
          {
            :headers => {
              :policy_id => policy.id,
              :eg_id => policy.eg_id
            },
            :routing_key => "info.events.policy.federal_reporting_eligibility_updated"
          },
          ""
        )
      end
    end
  end
end