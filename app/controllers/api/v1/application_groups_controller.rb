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
    Caches::MongoidCache.with_cache_for(Plan, Carrier, Employer) do
      render 'index'
    end
  end
  
  def show
    Caches::MongoidCache.with_cache_for(Plan, Carrier, Employer) do
      @group = ApplicationGroup.find(params[:id])
      render 'show'
    end
  end
end
