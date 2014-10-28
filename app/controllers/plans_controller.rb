class PlansController < ApplicationController
  def index
    @q = params[:q]
    @qf = params[:qf]
    @qd = params[:qd]

    if params[:q].present?
      @plans = Plan.by_name.search(@q, @qf, @qd).page(params[:page]).per(15)
    else
      @plans = Plan.by_name.page(params[:page]).per(15)
    end
  end

  def show
    @plan = Plan.find(params[:id])
  end

  def calculate_premium
    plan = Plan.find(params[:id])
    rate_period_date = extract_date(params[:rate_period_date])
    benefit_begin_date = extract_date(params[:benefit_begin_date])
    birth_date = extract_date(params[:birth_date])

    @rate = plan.rate(rate_period_date, benefit_begin_date, birth_date)

    respond_to do |format|
      format.js
    end
  end

  private

  def extract_date(raw_date)
    DateTime.strptime(raw_date, '%m/%d/%Y')
  end
end
