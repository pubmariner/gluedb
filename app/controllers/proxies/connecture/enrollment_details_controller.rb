class Proxies::Connecture::EnrollmentDetailsController < ApplicationController
  def show
    render :xml => Proxies::EnrollmentDetailsRequest.request(params[:id])
  end
end
