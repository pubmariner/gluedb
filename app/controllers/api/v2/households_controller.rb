class Api::V2::HouseholdsController < ApplicationController
  def index
    page_number = params[:page]
    page_number ||= 1
    @households = Household.all.page(page_number).per(15)
  end

  def show
    @household = Household.find(params[:id])
  end
end
