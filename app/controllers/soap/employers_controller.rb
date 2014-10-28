class Soap::EmployersController < Soap::SoapController

  def get_by_employer_id
    in_req = get_soap_body
    user_token = get_user_token(in_req)
    if fail_authentication(user_token)
      render :status => 401, :nothing => true
      return
    end
    employer_id = get_employer_id(in_req)
    if employer_id.blank?
      render :status => 422, :nothing => true
      return
    end
    @employers = Employer.where('id' => employer_id)
    render 'get_by_employer_id', :content_type => "text/xml"
  end


  def get_employer_id(xml_body)
    node = (xml_body.xpath("//employer_id", SOAP_NS) | xml_body.xpath("//cv_soap:employer_id", SOAP_NS)).first
    MayBlank.new(node).text.value
  end

end