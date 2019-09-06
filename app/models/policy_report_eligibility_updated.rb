require 'zip'

class PolicyReportEligibilityUpdated
  include Mongoid::Document
  include Mongoid::Timestamps

  field :event_time, type: Time
  field :policy_id, type: String
  field :eg_id, type: String

  XML_NS = "http://openhbx.org/api/terms/1.0"

  index({event_time: 1, policy_id: 1, eg_id: 1})

  def self.newest_event?(new_policy_id, new_eg_id, new_event_time)
    !self.where(:policy_id => new_policy_id, :eg_id => new_eg_id, :event_time => {"$gte" => new_event_time}).any?
  end

  def self.not_yet_seen_by_carrier?(new_policy_id, new_eg_id)
    self.where(:policy_id => new_policy_id, :new_eg_id => new_eg_id).any?
  end

  def self.create_new_event_and_remove_old(new_policy_id, new_eg_id, new_event_time, match_criteria)
    new_event = self.create!({
      policy_id: new_policy_id,
      eg_id: new_eg_id,
      event_time: new_event_time
    })
    self.where(match_criteria.merge({:_id => {"$ne" => new_event._id}})).each do |old_record|
      yield old_record
      old_record.destroy
    end
  end

  def self.store_and_yield_deleted(new_policy_id, new_eg_id, new_event_time)
    if not_yet_seen_by_carrier?(new_policy_id, new_eg_id)
      latest_time = ([new_event_time] + self.where(:policy_id => new_policy_id, :eg_id => new_eg_id).map(&:event_time)).max
      create_new_event_and_remove_old(

        new_policy_id,
        new_eg_id,
        latest_time,
        {:policy_id => new_policy_id, :eg_id => new_eg_id}) do |old_record|
          yield old_record
      end
    else
      create_new_event_and_remove_old(
        new_policy_id,
        new_eg_id,
        new_event_time,
        {:policy_id => new_policy_id, :eg_id => new_eg_id}) do |old_record|
          yield old_record
      end
    end
  end

  def self.clear_before(boundry_time)
    self.delete_all(event_time: {"$lt" => boundry_time})
  end
  
end
