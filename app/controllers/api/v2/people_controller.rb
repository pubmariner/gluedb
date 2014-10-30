require_relative "../../../../lib/search_abstractor"

class Api::V2::PeopleController < ApplicationController

  def index

    clean_hbx_member_id = Regexp.new(Regexp.escape(params[:hbx_id].to_s))

    # @people = Person.where('members.hbx_member_id' => clean_hbx_member_id)


    search = {'members.hbx_member_id' => clean_hbx_member_id}
    if(!params[:ids].nil? && !params[:ids].empty?)
      search['_id'] = {"$in" => params[:ids]}
    end

    @people = Person.where(search)

    page_number = params[:page]
    page_number ||= 1
    @people = @people.page(page_number).per(15)

    Caches::MongoidCache.with_cache_for(Carrier) do
      render "index"
    end
  end

  def show
    @person = Person.find(params[:id])
  end
end
