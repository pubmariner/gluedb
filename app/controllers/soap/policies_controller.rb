class Soap::PoliciesController < Soap::SoapController
  protect_from_forgery :except => [:get_by_policy_id]

  def get_by_policy_id
    in_req = get_soap_body
    user_token = get_user_token(in_req)
    if fail_authentication(user_token)
      render :status => 401, :nothing => true
      return
    end
    policy_id = get_policy_id(in_req)
    if policy_id.blank?
      render :status => 422, :nothing => true
      return
    end
    @policies = Policy.where('id' => policy_id)
    render 'get_by_policy_id', :content_type => "text/xml"
  end


  def get_policy_id(xml_body)
    node = (xml_body.xpath("//policy_id", SOAP_NS) | xml_body.xpath("//cv_soap:policy_id", SOAP_NS)).first
    MayBlank.new(node).text.value
  end

end
