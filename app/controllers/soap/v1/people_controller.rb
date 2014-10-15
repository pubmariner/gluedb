require_relative "../../../../lib/search_abstractor"

class Soap::V1::PeopleController < ApplicationController

  before_filter  lambda { |controller| authenticate_soap_request!(controller.action_name)} , :only=>[:index, :show]
  before_filter  lambda { |controller| valid_params?(controller.action_name)}, :only=>[:index, :show]
  skip_before_filter :authenticate_user_from_token!
  skip_before_filter :authenticate_me!
  protect_from_forgery :except => [:get_by_hbx_id]

  soap_service namespace: 'http://www.w3.org/2001/12/soap-envelope'

  @@logger = Logger.new("#{Rails.root}/log/soap.log")

  soap_action "index",
              :args => { :page => :integer, :hbx_id=> :integer, :user_token=> :string },
              :return => :strings
  def index
    @@logger.info "#{DateTime.now.to_s} class:#{self.class.name} method:#{__method__.to_s} params:#{params}"

    @people = SearchAbstractor::PeopleSearch.search(params)

    Caches::MongoidCache.with_cache_for(Carrier) do
      @people_xml = render_to_string "api/v1/people/index"
    end

    render :soap => @people_xml.to_s
  end

  soap_action "show",
              :args => { :id => :string, :user_token=> :string },
              :return => :string
  def show
    @@logger.info "#{DateTime.now.to_s} class:#{self.class.name} method:#{__method__.to_s} params:#{params}"

    @person = Person.find(params[:id])
    @person_xml = render_to_string "/api/v1/people/show"

    render :soap => @person_xml.to_s
  end

  private

  def valid_params?(action)
    @@logger.info "#{DateTime.now.to_s} class:#{self.class.name} method:#{__method__.to_s} action_name#{action}: params:#{params}"

    case action_name.to_s
      when "show"
        unless  params["Envelope"]["Body"][action].key? "id"
          render :status => :unprocessable_entity, :nothing => true
          return false
        end
      when "index"
        unless  params["Envelope"]["Body"][action].key? "hbx_id"
          render :status => :unprocessable_entity, :nothing => true
          return false
        end
    end

    return true

  end

end
