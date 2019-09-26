module ExternalEvents
  class ExternalFederalReportingNotification
#this class sends a message to EA that an h41 has been place on the s3 bucket
    def self.notify(s3_response, policy, time = Time.now)
      ::Amqp::EventBroadcaster.with_broadcaster do |b|
        b.broadcast(
          {
            :headers => {
              :file_name =>  s3_response[:object].key,
              :policy_id => policy.id,
              :eg_id => policy.eg_id
            },
            :routing_key => "info.events.transport_artifact.transport_requested"
          },
          ""
        )
      end
    end

  end
end 