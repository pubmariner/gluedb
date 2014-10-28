require_relative "../../../../lib/search_abstractor"

class Soap::V1::ApplicationGroupsController < ApplicationController

  before_filter  lambda { |controller| authenticate_soap_request!(controller.action_name)} , :only=>[:index, :show]
  before_filter  lambda { |controller| valid_params?(controller.action_name)}, :only=>[:index, :show]
  skip_before_filter :authenticate_user_from_token!
  skip_before_filter :authenticate_me!
  protect_from_forgery :except => [:get_by_hbx_id]

  soap_service namespace: 'http://www.w3.org/2001/12/soap-envelope'

  @@logger = Logger.new("#{Rails.root}/log/soap.log")

  soap_action "index",
              :args => { :page => :integer, :ids=> [:string], :user_token=> :string },
              :return => :strings
  def index
    @@logger.info "#{DateTime.now.to_s} class:#{self.class.name} method:#{__method__.to_s} params:#{params}"

    @groups, lt_p = SearchAbstractor::ApplicationGroupsSearch.search(params)

    @@logger.info "#{DateTime.now.to_s} class:#{self.class.name} method:#{__method__.to_s} groups:#{@groups.inspect} lt_p:#{lt_p}"

    Caches::CustomCache.with_custom_cache(Person, "ag_lookup", lt_p) do
      Caches::MongoidCache.with_cache_for(Carrier) do
        @groups_xml = render_to_string '/api/v1/application_groups/index'
      end
    end
    Rails.cache.delete_matched("people/by_member_id")

    render :soap => @groups_xml

  end

  soap_action "show",
              :args => { :id => :string, :user_token=> :string },
              :return => :string
  def show
    @@logger.info "#{DateTime.now.to_s} class:#{self.class.name} method:#{__method__.to_s} params:#{params}"

    Caches::MongoidCache.with_cache_for(Carrier) do
      @group = ApplicationGroup.find(params[:id])
      @group_xml = render_to_string '/api/v1/application_groups/show'
      @group_xml = render_to_string '/api/v1/application_groups/show'
    end
    render :soap => @group_xml.to_s
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
        unless  params["Envelope"]["Body"][action]["ids"].present?
          render :status => :unprocessable_entity, :nothing => true
          return false
        end
    end

    return true

  end


end