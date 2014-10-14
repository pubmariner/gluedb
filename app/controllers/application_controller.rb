class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user_from_token!
  before_filter :authenticate_me!
  rescue_from Mongoid::Errors::DocumentNotFound, with: :id_not_found
  rescue_from CanCan::AccessDenied, with: :access_denied

  def authenticate_me!
    # Skip auth if you are trying to log in
    if controller_name.downcase == "accounts"
      return true
    end
    authenticate_user!
  end

  def flash_message(type, text)
    flash[type] ||= []
    flash[type] << text
  end

  def flash_message_now(type, text)
    flash.now[type] ||= []
    flash.now[type] << text
  end

  def id_not_found
    render file: 'public/404.html', status: 404
  end

  def access_denied
    render file: 'public/403.html', status: 403
  end

  private

  def authenticate_user_from_token!

    user_token = params[:user_token].presence
    user = user_token && User.find_by_authentication_token(user_token.to_s)

    if user
      sign_in user, store: false
    end

  end

  def authenticate_soap_request!(action)


    if params.key? "user_token"
      parans[:user_token] = params["user_token"]
    else
      params[:user_token] = params["Envelope"]["Body"][action]["user_token"]
    end

    if authenticate_user_from_token!.nil?
      render :status => 403, :nothing => true
      return false
    end

    return true
  end


end
