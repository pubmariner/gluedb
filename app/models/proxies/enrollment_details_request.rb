module Proxies
  class EnrollmentDetailsRequest < Proxies::SimpleSoapRequest
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

    def service_location 
      "/soa-infra/services/COTS/ESB_GetInsurancePlanDetailsDService/GetInsurancePlanDetails_Mediator_ep"
    end
  end
end
