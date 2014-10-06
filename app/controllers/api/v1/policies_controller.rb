class Api::V1::PoliciesController < ApplicationController
  def index
    clean_eg_id = Regexp.new(Regexp.escape(params[:enrollment_group_id].to_s))

    search = {"eg_id" => clean_eg_id}
    if(!params[:ids].nil? && !params[:ids].empty?)
      search['_id'] = {"$in" => params[:ids]}
    end
    
    @policies = Policy.where(search)

    page_number = params[:page]
    page_number ||= 1
    @policies = @policies.page(page_number).per(20)

    Caches::MongoidCache.with_cache_for(Carrier) do
      render "index"
    end
  end

  def show
    @policy = Policy.find(params[:id])
    Caches::MongoidCache.with_cache_for(Carrier) do
      render 'show'
    end
  end
end
