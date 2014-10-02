class Comment
  include Mongoid::Document
  include Mongoid::Timestamps

  PRIORITY_TYPE = %W[low normal high]

  field :content, type: String
  field :priority, type: String, default: "normal"
  field :user, type: String

  validates_inclusion_of :priority, in: PRIORITY_TYPE, message: "Invalid priority"

  embedded_in :application_group
  embedded_in :household
  embedded_in :person

  def high?
    priority == "high"
  end

  def low?
    priority == "low"
  end

end
