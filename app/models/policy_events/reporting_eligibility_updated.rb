module PolicyEvents
  class ReportingEligibilityUpdated
    include Mongoid::Document
    include Mongoid::Timestamps

    field :event_time, type: Time
    field :processed_at, type: Time
    field :policy_id, type: String
    field :eg_id, type: String
    field :worker_id, type: String
    field :status, type: String, default: "queued"

    index({event_time: 1, worker_id: 1, status: 1})
    index({policy_id: 1, status: 1})

    def self.store_new_event(policy_id, eg_id, event_time = Time.now)
      old_record = self.where({
        :status => "queued",
        :policy_id => policy_id
      }).first
      if old_record
        old_record.update_attributes!({event_time: event_time})
      else
        self.create!({
          policy_id: policy_id,
          eg_id: eg_id,
          event_time: event_time
        })
      end
    end

    def self.events_for_processing(time = Time.now)
      # Use the current OS PID to take ownership of our batch
      worker_pid = Process.pid.to_s
      self.where({
        :status => "queued",
        :event_time => {"$lte" => time}
      }).update_all(
        {"$set" => {:status => "processing", :worker_id => worker_pid}}
      )
      self.where({
        :status => "processing",
        :worker_id => worker_pid
      }).each do |record|
        yield record
        record.update_attributes!({
          :status => "processed",
          :processed_at => Time.now
        })
      end
    end
  end
end