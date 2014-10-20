require_relative "../../../../lib/search_abstractor"

class Soap::V1::EmployersController < ApplicationController

  before_filter  lambda { |controller| authenticate_soap_request!(controller.action_name)} , :only=>[:index, :show]
  before_filter  lambda { |controller| valid_params?(controller.action_name)}, :only=>[:index, :show]
  skip_before_filter :authenticate_user_from_token!
  skip_before_filter :authenticate_me!
  protect_from_forgery :except => [:get_by_hbx_id]

  soap_service namespace: 'http://www.w3.org/2001/12/soap-envelope'

  @@logger = Logger.new("#{Rails.root}/log/soap.log")

  soap_action "index",
              :args => { :page => :integer, :hbx_id=> :integer, :fein=> :integer, :user_token=> :string },
              :return => :strings
  def index
    @@logger.info "#{DateTime.now.to_s} class:#{self.class.name} method:#{__method__.to_s} params:#{params}"

    @employers = SearchAbstractor::EmployersSearch.search(params)

    Caches::MongoidCache.with_cache_for(Carrier) do
      @employers_xml = render_to_string "api/v1/employers/index"
    end

    @@logger.info "#{DateTime.now.to_s} class:#{self.class.name} method:#{__method__.to_s} @employers_xml:#{@employers_xml.inspect}"


    render :soap => @employers_xml
  end

  soap_action "show",
              :args => { :id => :string, :user_token=> :string },
              :return => :string
  def show
    @@logger.info "#{DateTime.now.to_s} class:#{self.class.name} method:#{__method__.to_s} params:#{params}"

    @employer = Employer.find(params[:id])
    @@logger.info "#{DateTime.now.to_s} class:#{self.class.name} method:#{__method__.to_s} @employer:#{@employer.inspect}"

    @employer_xml = render_to_string "api/v1/employers/show"

    render :soap => @employer_xml
  end

  private

  def valid_params?(action)
    @@logger.info "#{DateTime.now.to_s} class:#{self.class.name} method:#{__method__.to_s} action_name#{action}: params:#{params}"

    case action_name.to_s
      when "show"
        unless  params["Envelope"]["Body"][action]["id"].present?
          render :status => :unprocessable_entity, :nothing => true
          return false
        end
      when "index"
        unless  params["Envelope"]["Body"][action]["hbx_id"].present? || params["Envelope"]["Body"][action]["fein"].present?
          render :status => :unprocessable_entity, :nothing => true
          return false
        end
    end

    return true

  end


end
