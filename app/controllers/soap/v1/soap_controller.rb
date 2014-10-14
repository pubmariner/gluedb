class SoapController < ApplicationController

  def authenticate_soap_request!(action)


    if params.key? "user_token"
      parans[:user_token] = params["user_token"]
    else
      @@logger.info "\n\n\n\n\n\n\n#{DateTime.now.to_s} class:#{self.class.name} method:#{__method__.to_s} caller_method:#{action}"
      params[:user_token] = params["Envelope"]["Body"][action]["user_token"]
    end

    if authenticate_user_from_token!.nil?
      render :status => 403, :nothing => true
      return false
    end

    return true
  end

end