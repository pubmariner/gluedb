module Proxies
  class EnrollmentDetailsRequest 
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
<ns1:get-enrollment-details-request xmlns:ns1="Connecture">
<ns1:enrollment-id>#{en_id}</ns1:enrollment-id>
</ns1:get-enrollment-details-request>
</soap:Body>
</soap:Envelope>
XMLCODE
      soap_template
    end

    def endpoint
      osb_host + "/soa-infra/services/COTS/ESB_GetInsurancePlanDetailsDService/GetInsurancePlanDetails_Mediator_ep"
    end

    def osb_host
      ExchangeInformation.osb_host
    end
  end
end
