require "rails_helper"

describe PolicyEvents::ReportingEligibilityUpdated do
  after :each do
    PolicyEvents::ReportingEligibilityUpdated.where({}).delete_all
  end

  context "#events_for_processing" do
    let(:unprocessed_event_1) do
      PolicyEvents::ReportingEligibilityUpdated.create!(
        policy_id: Moped::BSON::ObjectId.new,
        eg_id: Moped::BSON::ObjectId.new,
        status: 'queued',
        event_time: Time.now - 1.week,
        worker_id: "-5"
      )
    end
    let(:unprocessed_event_2) do
      PolicyEvents::ReportingEligibilityUpdated.create!(
        policy_id: Moped::BSON::ObjectId.new,
        eg_id: Moped::BSON::ObjectId.new,
        status: 'queued',
        event_time: Time.now - 1.week,
        worker_id: "-5"
      )
    end
    let(:already_processed_event) do
      PolicyEvents::ReportingEligibilityUpdated.create!(
        policy_id: Moped::BSON::ObjectId.new,
        eg_id: Moped::BSON::ObjectId.new,
        status: 'processed',
        event_time: Time.now - 1.week,
        worker_id: "-5"
      )
    end
    let(:being_processed_event) do
      PolicyEvents::ReportingEligibilityUpdated.create!(
        policy_id: Moped::BSON::ObjectId.new,
        eg_id: Moped::BSON::ObjectId.new,
        status: 'processing',
        event_time: Time.now - 1.week,
        worker_id: "-5"
      )
    end

    before :each do
      unprocessed_event_1
      unprocessed_event_2
      already_processed_event
      being_processed_event
    end

    it "ignores already processed events" do
      found_events = []
      PolicyEvents::ReportingEligibilityUpdated.events_for_processing do |found_event|
        found_events << found_event.id
      end
      expect(found_events).to_not include(already_processed_event.id)
    end

    it "provides a list of events due for processing" do
      found_events = []
      PolicyEvents::ReportingEligibilityUpdated.events_for_processing do |found_event|
        found_events << found_event.id
      end
      expect(found_events).to include(unprocessed_event_1.id)
      expect(found_events).to include(unprocessed_event_2.id)
    end

    it "marks the provided events processed" do
      found_events = []
      PolicyEvents::ReportingEligibilityUpdated.events_for_processing do |found_event|
        found_events << found_event.id
      end
      expect(PolicyEvents::ReportingEligibilityUpdated.find(unprocessed_event_1.id).status).to eq("processed")
      expect(PolicyEvents::ReportingEligibilityUpdated.find(unprocessed_event_2.id).status).to eq("processed")
    end

    it "ignores events being worked by someone else" do
      found_events = []
      PolicyEvents::ReportingEligibilityUpdated.events_for_processing do |found_event|
        found_events << found_event.id
      end
      expect(found_events).to_not include(being_processed_event.id)
    end
  end

  context "#store_new_event" do
    let(:existing_unprocessed_record) do
      PolicyEvents::ReportingEligibilityUpdated.create!(
        policy_id: Moped::BSON::ObjectId.new,
        eg_id: Moped::BSON::ObjectId.new,
        status: 'queued',
        event_time: Time.now - 1.week,
        worker_id: "-5"
      )
    end
    let(:existing_processed_record) do
      PolicyEvents::ReportingEligibilityUpdated.create!(
        policy_id: Moped::BSON::ObjectId.new,
        eg_id: Moped::BSON::ObjectId.new,
        status: 'processed',
        event_time: Time.now - 1.week,
        worker_id: "-5"
      )
    end

    it "updates an existing record if there is a matching unprocessed record" do
      existing_unprocessed_record
      old_event_time = existing_unprocessed_record.event_time
      updated_record = PolicyEvents::ReportingEligibilityUpdated.store_new_event(
        existing_unprocessed_record.policy_id,
        existing_unprocessed_record.eg_id
      )
      expect(updated_record.id).to eq(existing_unprocessed_record.id)
      expect(old_event_time).to be < (updated_record.event_time)
    end

    it "creates a new record if there is not a matching unprocessed record" do
      existing_unprocessed_record
      new_record = PolicyEvents::ReportingEligibilityUpdated.store_new_event(
        Moped::BSON::ObjectId.new,
        existing_unprocessed_record.eg_id
      )
      expect(new_record.id).to_not eq(existing_unprocessed_record.id)
    end

    it "creates a new record if there is an already processed record for the same policy" do
      existing_processed_record
      new_record = PolicyEvents::ReportingEligibilityUpdated.store_new_event(
        existing_processed_record.policy_id,
        existing_processed_record.eg_id
      )
      expect(new_record.id).to_not eq(existing_processed_record.id)
    end
  end
end