class PlanYear
  include Mongoid::Document
  include Mongoid::Timestamps

  field :start_date, type: Date
  field :end_date, type: Date
  field :open_enrollment_start, type: Date
  field :open_enrollment_end, type: Date
  field :fte_count, type: Integer
  field :pte_count, type: Integer

  belongs_to :employer
  belongs_to :broker
  
  embeds_many :elected_plans
end
