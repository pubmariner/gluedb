class CarefirstPolicyUpdatesController < ApplicationController

  class Listener
    def initialize(controller)
      @controller = controller
      @errors = []
    end

    def policy_not_found(policy_id)
      @errors << "Policy(#{policy_id}) not found."
    end

    def invalid_dates(dates)
      @errors << "Invalid date combination: Begin-#{dates[:begin_date]}, End-#{dates[:end_date]}."
    end

    def policy_status_is_same
      @errors << "Policy status is the same."
    end
    
    def subscriber_id_mismatch(details)
      @error << "Subscriber ID does not match. Provided: #{details[:provided]}, Existing: #{details[:existing]}"
    end
      
    def enrolled_count_mismatch(details)
      @error << "Enrolled Count does not match. Provided: #{details[:provided]}, Existing: #{details[:existing]}"
    end

    def plan_mismatch(details)
      @error << "Plan does not match. Provided: #{details[:provided]}, Existing: #{details[:existing]}"
    end

    def enrollee_end_date_is_different
      @error << "An enrollee's end date doesn't match the subscriber's"
    end

    def fail
      @controller.respond_to_failure(@errors)
    end

    def success
      @controller.respond_to_success
    end
  end


  def create
    @carefirst_policy_update = params[:carefirst_policy_update]

    status_map = {
      'canceled' => 'carrier_canceled',
      'terminated' => 'carrier_terminated',
      'effectuated' => 'effectuated'
    }

    request_model = {
      policy_id: @carefirst_policy_update[:policy_hbx_id],
      status: status_map[@carefirst_policy_update[:status]],
      begin_date: @carefirst_policy_update[:begin_date],
      end_date: @carefirst_policy_update[:end_date],
      subscriber_id: @carefirst_policy_update[:subscriber_hbx_id],
      enrolled_count: @carefirst_policy_update[:enrolled_count],
      hios_plan_id: @carefirst_policy_update[:hios_plan_id]
    }

    UpdatePolicyStatus.new(Policy).execute(request_model, Listener.new(self))
  end

  def respond_to_success
    respond_to do |format|
      format.json { render :nothing => true, :status => 202 }
    end
  end

  def respond_to_failure(errors)
    respond_to do |format|
      format.json { render :json => errors.to_json, :status => 422 }
    end
  end

  def upload_csv
    file = params[:policy_status_file]

    connection = Bunny.new
    connection.start
    exchange = connection.create_channel.default_exchange

    exchange.publish(
      file.read.force_encoding('utf-8'),
      :routing_key => "hbx.csv_batch_process",
      :headers => {
        :file_name => download_filename(file),
        :csv_queue => "hbx.cf_update_policy",
        :submitted_by => current_user.email
      }
    )
    connection.close
  end

  private

  def download_filename(file)
    fname = file.original_filename
    File.basename(fname,File.extname(fname)) + "_status.csv"
  end
end












