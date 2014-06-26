class EmployersController < ApplicationController
  def index
    @q = params[:q]
    @qf = params[:qf]
    @qd = params[:qd]

    @employers = Employer.search(@q, @qf, @qd).page(params[:page]).per(12)
    respond_to do |format|
	    format.html # index.html.erb
	    format.json { render json: @employers }
	  end
  end

  def show
    @q_person = params[:q_person]
    @qf_person = params[:qf_person]
    @qd_person = params[:qd_person]

    @employer = Employer.find(params[:id])

    @premium_payments = @employer.premium_payments.all.order_by(paid_at: :desc).page(params[:premium_payments_page]).per(12)

    @elected_plans = @employer.elected_plans.all.order_by(carrier_name: 1, plan_name: 1)
    
    if params[:q_person].present?
      @employees = @employer.employees.search(@q_person, @qf_person, @qd_person).page(params[:employee_page]).per(12)
    else
      @employees = @employer.employees.all.order_by(name_last: 1, name_first: 1).page(params[:employee_page]).per(12)
    end

	  respond_to do |format|
		  format.html # index.html.erb
		  format.json { render json: @employer }
		  format.xml
      format.js
    end
  end

  def new
    @employer = Employer.new
    @employer.addresses.build
    @employer.phones.build
    @employer.emails.build

    @brokers = Broker.all.order_by(name_last: 1, name_first: 1)
    @carriers = Carrier.all.order_by(name: 1)
    @plans = Plan.all.order_by(name: 1)

    @employer.addresses.first.city = "Washington"
    @employer.addresses.first.state = "DC"

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @employer }
    end
  end

  def edit
    @employer = Employer.find(params[:id])
    @employer.addresses.build if @employer.addresses.empty?
    @employer.phones.build if @employer.phones.empty?
    @employer.emails.build if @employer.emails.empty?

    @brokers = Broker.all.order_by(name_last: 1, name_first: 1)
    @selected_broker = Broker.find(@employer.broker) if @employer.broker

    @carriers = Carrier.all.order_by(name: 1)
    @selected_carriers = Carrier.find(@employer.carriers) if @employer.carriers

    @plans = Plan.all.order_by(name: 1)
    @selected_plans = Plan.find(@employer.plans) if @employer.plans
  end

  def create
    @employer = Employer.new(params[:employer])

    respond_to do |format|
      if @employer.save
        format.html { redirect_to @employer, notice: 'Employer was successfully created.' }
        format.json { render json: @employer, status: :created, location: @employer }
      else
        format.html { render action: "new" }
        format.json { render json: @employer.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @employer = Employer.find(params[:id])

    respond_to do |format|
      if @employer.update_attributes(params[:employer])
        format.html { redirect_to @employer, notice: 'Employer was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @employer.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @employer = Employer.find(params[:id])
    @employer.destroy

    respond_to do |format|
      format.html { redirect_to persons_url }
      format.json { head :no_content }
    end
  end

  def group
    @employer = Employer.find(params[:id])

    respond_to do |format|
      format.xml
    end
  end

end
