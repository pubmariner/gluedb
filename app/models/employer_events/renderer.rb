module EmployerEvents
  class Renderer
    XML_NS = "http://openhbx.org/api/terms/1.0"

    EVENT_WHITELIST = %w(
address_changed
contact_changed
fein_corrected
name_changed
broker_added
broker_terminated
general_agent_added
general_agent_terminated
benefit_coverage_initial_application_eligible
benefit_coverage_renewal_carrier_dropped
benefit_coverage_renewal_application_eligible
    )

    EXCLUDED_FOR_NOW = %w(
benefit_coverage_period_terminated_voluntary
benefit_coverage_period_terminated_nonpayment
benefit_coverage_period_terminated_relocated
benefit_coverage_renewal_terminated_voluntary
benefit_coverage_renewal_terminated_ineligible
benefit_coverage_period_reinstated
    )

    attr_reader :employer_event
    attr_reader :timestamp

    def initialize(e_event)
      @employer_event = e_event
      @timestamp = e_event.event_time
    end

    # Return true if we rendered anything
    def render_for(carrier, out)
      unless EVENT_WHITELIST.include?(@employer_event.event_name)
        return false
      end

      doc = Nokogiri::XML(employer_event.resource_body)
      unless doc.xpath("//cv:elected_plans/cv:elected_plan/cv:carrier/cv:id/cv:id[text() = '#{carrier.hbx_carrier_id}']", {:cv => XML_NS}).any?
        return false
      end

      doc.xpath("//cv:elected_plans/cv:elected_plan", {:cv => XML_NS}).each do |node|
        carrier_id = node.at_xpath("cv:carrier/cv:id/cv:id", {:cv => XML_NS}).content
        if carrier_id != carrier.hbx_carrier_id 
          node.remove
        end
      end


      doc.xpath("//cv:employer_census_families", {:cv => XML_NS}).each do |node|
        node.remove
      end
      doc.xpath("//cv:benefit_group/cv:reference_plan", {:cv => XML_NS}).each do |node|
        node.remove
      end
      doc.xpath("//cv:benefit_group/cv:elected_plans[not(cv:elected_plan)]", {:cv => XML_NS}).each do |node|
        node.remove
      end
      doc.xpath("//cv:broker_agency_profile[not(cv:brokers)]", {:cv => XML_NS}).each do |node|
        node.remove
      end
      doc.xpath("//cv:employer_profile/cv:brokers[not(cv:broker_account)]", {:cv => XML_NS}).each do |node|
        node.remove
      end
      doc.xpath("//cv:benefit_group[not(cv:elected_plans)]", {:cv => XML_NS}).each do |node|
        node.remove
      end
      doc.xpath("//cv:plan_year/cv:benefit_groups[not(cv:benefit_group)]", {:cv => XML_NS}).each do |node|
        node.remove
      end
      doc.xpath("//cv:plan_year[not(cv:benefit_groups)]", {:cv => XML_NS}).each do |node|
        node.remove
      end

      has_plan_year_that_ends_later = false
      # Check that at least one plan year for this carrier is not in the past
      doc.xpath("//cv:plan_year", {:cv => XML_NS}).each do |node|
        node = node.xpath("cv:plan_year_end", {:cv => XML_NS}).first
        if node
          end_date = (Date.strptime(node.content, "%Y%m%d")) rescue nil
          if end_date
            if end_date > Date.today
              has_plan_year_that_ends_later = true
              break
            end
          end
        end
      end
      unless has_plan_year_that_ends_later
        return false
      end
      
      # Check that at least one plan year for this carrier that starts later
      # If one exists, block transmission of events where we 'leave' that carrier
      has_plan_year_that_starts_later = false
      doc.xpath("//cv:plan_year", {:cv => XML_NS}).each do |node|
        node = node.xpath("cv:plan_year_start", {:cv => XML_NS}).first
        if node
          start_date = (Date.strptime(node.content, "%Y%m%d")) rescue nil
          if start_date 
            if start_date > Date.today
              has_plan_year_that_starts_later = true
              break
            end
          end
        end
      end
      if has_plan_year_that_starts_later && (employer_event.event_name == "benefit_coverage_renewal_carrier_dropped")
        return false
      end

      is_renewal_add_event = (employer.event_name == "benefit_coverage_renewal_carrier_dropped")

      if is_renewal_add_event && !has_plan_year_that_starts_later
        return false
      end

      event_header = <<-XMLHEADER
                        <employer_event>
                                <event_name>urn:openhbx:events:v1:employer##{employer_event.event_name}</event_name>
                                <resource_instance_uri>
                                        <id>urn:openhbx:resource:organization:id##{employer_event.employer_id}</id>
                                </resource_instance_uri>
                                <body>
      XMLHEADER
      event_trailer = <<-XMLTRAILER
                                </body>
                        </employer_event>
      XMLTRAILER
      out << event_header
      out << doc.to_xml(:save_with => Nokogiri::XML::Node::SaveOptions::NO_DECLARATION, :indent => 2)
      out << event_trailer
      true
    end
  end
end
