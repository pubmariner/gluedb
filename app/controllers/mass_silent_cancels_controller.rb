class MassSilentCancelsController < ApplicationController
  load_and_authorize_resource :class => "VocabUpload"

  def new
  end

  def create
    file = params[:mass_silent_cancels_file]

    requests = CsvRequest.create_many(file.read.force_encoding('utf-8'), current_user.email)
    change_address = ChangeMemberAddress.new(transmitter)
    end_coverage = EndCoverage.new(EndCoverageAction)

    out_stream = CSV.generate do |csv|
      csv << ["policy_id"]
      requests.each do |csv_request|
        request = EndCoverageRequest.for_mass_silent_cancels(csv_request.to_hash, current_user.email)
        end_coverage.execute(request)
      end
    end

    flash_message(:success, "Upload successful.")
    redirect_to new_vocab_upload_path
  end

  def transmitter
    NullPolicyMaintenance.new
  end
end
