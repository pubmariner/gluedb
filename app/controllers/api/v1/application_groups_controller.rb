class Api::V1::ApplicationGroupsController < ApplicationController
  def index
    page_number = params[:page]
    page_number ||= 1
    @groups = ApplicationGroup.all.page(page_number).per(15)
  end
  
  def show
    Caches::MongoidCache.with_cache_for(Plan, Carrier, Employer) do
      @group = ApplicationGroup.find(params[:id])
      render 'show'
    end
  end
end
