class Soap::IndividualsController < Soap::SoapController
  protect_from_forgery :except => [:get_by_hbx_id]

  def get_by_hbx_id
    in_req = get_soap_body
    user_token = get_user_token(in_req)
    if fail_authentication(user_token)
      render :status => 401, :nothing => true
      return
    end
    hbx_id = get_hbx_id(in_req)
    if hbx_id.blank?
      render :status => 422, :nothing => true
      return
    end
    @people = Person.where('members.hbx_member_id' => hbx_id)
    render 'get_by_hbx_id', :content_type => "text/xml"
  end


  def get_hbx_id(xml_body)
    node = (xml_body.xpath("//hbx_id", SOAP_NS) | xml_body.xpath("//cv_soap:hbx_id", SOAP_NS)).first
    MayBlank.new(node).text.value
  end

end
