class Api::V1::ApplicationGroupsController < ApplicationController

  def index
    search = {}
    if(!params[:ids].nil? && !params[:ids].empty?)
      search['_id'] = {"$in" => params[:ids]}
    end
    
    @groups = ApplicationGroup.where(search)
    
    page_number = params[:page]
    page_number ||= 1
    @groups = @groups.page(page_number).per(15)
  end
  
  def show
    @group = ApplicationGroup.find(params[:id])
  end
end
