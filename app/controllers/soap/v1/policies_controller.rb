require_relative "../../../../lib/search_abstractor"

class Soap::V1::PoliciesController < ApplicationController

  before_filter  lambda { |controller| authenticate_soap_request!(controller.action_name)} , :only=>[:index, :show]

  skip_before_filter :authenticate_user_from_token!
  skip_before_filter :authenticate_me!
  protect_from_forgery :except => [:get_by_hbx_id]

  @@logger = Logger.new("#{Rails.root}/log/soap.log")

  soap_service namespace: 'http://www.w3.org/2001/12/soap-envelope'

  soap_action "index",
              :args => { :page => :integer, :enrollment_group_id=> :integer, :user_token=> :string},
              :return => :string
  def index

    @@logger.info "#{DateTime.now.to_s} class:#{self.class.name} method:#{__method__.to_s} params:#{params}"

    @policies = SearchAbstractor::Policies.search(params)

    Caches::MongoidCache.with_cache_for(Carrier) do
      @policies_xml = render_to_string "api/v1/policies/index"
    end

    render :soap => @policies_xml
  end

  soap_action "show",
              :args => { :id => :integer, :user_token=> :string },
              :return => :string
  def show
    @@logger.info "#{DateTime.now.to_s} class:#{self.class.name} method:#{__method__.to_s} params:#{params}"

    @policy = Policy.find(params[:id])

    @policy_xml = render_to_string "api/v1/policies/show"

    render :soap => @policy_xml
  end

end
