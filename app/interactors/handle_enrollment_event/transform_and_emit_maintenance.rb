module HandleEnrollmentEvent
  # Transmit the X12 for the maintenance action
  class TransformAndEmitMaintenance
    include Interactor

    # Context requires:
    # - policy_details (HandleEnrollmentEvent::PolicyDetails)
    # - plan_details (HandleEnrollmentEvent::PlanDetails)
    # - amqp_connection (A connection to an amqp service)
    # - raw_event_xml (a string containing the raw event xml)
    def call
      action_xml = context.raw_event_xml
      edi_builder = EdiCodec::X12::BenefitEnrollment.new(action_xml)
      x12_xml = edi_builder.call.to_xml
      publish_to_bus(x12_xml)
    end

    def publish_to_bus(x12_payload)
      ::Amqp::ConfirmedPublisher.with_confirmed_channel(context.amqp_connection) do |chan|
         ex = chan.default_exchange
         ex.publish(x12_payload, :routing_key => "hbx.maintenance_messages", :headers => {
           "market" => context.primary_policy_action.policy_details.market,
           "file_name" => determine_file_name
         })
      end
    end

    def determine_file_name
      market_identifier = (context.policy_details.market == "shop") ? "S" : "I"
      carrier_identifier = context.plan_details.found_plan.carrier.abbrev.upcase
      "834_" + context.policy_details.transaction_id + "_" + carrier_identifier + "_C_M_" + market_identifier + "_1.xml"
    end
  end
end
