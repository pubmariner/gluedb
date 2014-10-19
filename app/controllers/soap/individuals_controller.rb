class Soap::IndividualsController < ApplicationController
  skip_before_filter :authenticate_user_from_token!
  skip_before_filter :authenticate_me!
  protect_from_forgery :except => [:get_by_hbx_id, :wsdl]

  SOAP_NS = {
    :soap => 'http://www.w3.org/2001/12/soap-envelope',
    :cv_soap => 'http://openhbx.org/api/transports/soap/1.0'
  }

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
    render 'index', :content_type => "text/xml"
  end

  def wsdl
    render action: 'wsdl', :content_type => "text/xml", :formats => [:xml]
  end

  def fail_authentication(user_token)
    user = user_token && User.find_by_authentication_token(user_token.to_s)

    if user
      sign_in user, store: false
      return false
    end
    true
  end

  def get_user_token(xml_body)
    node = (xml_body.xpath("//user_token", SOAP_NS) | xml_body.xpath("//cv_soap:user_token", SOAP_NS)) .first
    MayBlank.new(node).text.value
  end

  def get_hbx_id(xml_body)
    node = (xml_body.xpath("//hbx_id", SOAP_NS) | xml_body.xpath("//cv_soap:hbx_id", SOAP_NS)).first
    MayBlank.new(node).text.value
  end

  def get_soap_body
    Nokogiri::XML(request.body.read)
  end
end
