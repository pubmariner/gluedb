class Api::V1::EmployersController < ApplicationController
  def index
    clean_hbx_id = Regexp.new(Regexp.escape(params[:hbx_id].to_s))
    clean_fein = Regexp.new(Regexp.escape(params[:fein].to_s))

    @employers = Employer.where("hbx_id" => clean_hbx_id, "fein" => clean_fein)
    page_number = params[:page]
    page_number ||= 1
    @employers = @employers.page(page_number).per(15)
  end

  def show
    @employer = Employer.find(params[:id])
  end

  def old_cv
    @employer = Employer.find(params[:id])
  end
end
