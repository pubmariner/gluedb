class Proxies::Curam::RetrieveDemographicsController < ApplicationController
  def show
    render :xml => Proxies::RetrieveDemographicsRequest.request(params[:id])
  end
end
