module Proxies
  class RetrieveDemographicsRequest
    def self.request(en_id)
      self.new.request(en_id)
    end

    def request(en_id)
      uri = URI.parse(endpoint)
      req = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' =>'text/xml'})
      req.body = template(en_id)
      Net::HTTP.new(uri.host, uri.port).request(req).body
    end

    def template(en_id)
      soap_template = <<-XMLCODE
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
<soap:Body>
<ns1:retrieveDemographicsAndEligibilityDetails xmlns:ns1="http://remote.adapter.planmanagement.curam">
<ns1:enrollmentDetails xmlns:ns2="http://struct.adapter.planmanagement.curam/xsd">
<ns2:enrollmentID>#{en_id}</ns2:enrollmentID>
</ns1:enrollmentDetails>
</ns1:retrieveDemographicsAndEligibilityDetails>
</soap:Body>
</soap:Envelope>
XMLCODE
      soap_template
    end

    def endpoint
      osb_host + "/soa-infra/services/COTS/PlanManagementCrmCmpService/PlanManagementCrmService_ep"
    end

    def osb_host
      "http://dhsdcasesbsoaappuat01.dhs.dc.gov:8001"
    end
  end
end
