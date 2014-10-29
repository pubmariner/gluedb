class PlanYear
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning
  include MergingModel

  field :start_date, type: Date
  field :end_date, type: Date
  field :open_enrollment_start, type: Date
  field :open_enrollment_end, type: Date
  field :fte_count, type: Integer
  field :pte_count, type: Integer

  belongs_to :employer
  belongs_to :broker

  embeds_many :elected_plans

  def self.make(data)
    plan_year = PlanYear.new
    plan_year.open_enrollment_start = data[:open_enrollment_start]
    plan_year.open_enrollment_end = data[:open_enrollment_end]
    plan_year.start_date = Date.parse(data[:start_date])
    plan_year.end_date = Date.parse(data[:end_date]) unless data[:end_date].blank?
    plan_year.broker = Broker.find_by_npn(data[:broker_npn])
    plan_year.fte_count = data[:fte_count]
    plan_year.pte_count = data[:pte_count]

    data[:plans].each do |plan_data|
      plan = Plan.find_by_hios_id_and_year(plan_data[:qhp_id], plan_year.start_date.year)
      raise plan_data[:qhp_id].inspect if plan.nil?
      plan_year.elected_plans << ElectedPlan.new(
        :carrier_id => plan.carrier_id,
        :qhp_id => plan_data[:qhp_id],
        :coverage_type => plan_data[:coverage_type],
        :metal_level => plan.metal_level,
        :hbx_plan_id => plan.hbx_plan_id,
        :original_effective_date => plan_data[:original_effective_date],
        :plan_name => plan.name,
        :carrier_policy_number => plan_data[:policy_number],
        :carrier_employer_group_id => plan_data[:group_id]
      )
    end
    
    plan_year
  end

  def match(other)
    return false if other.nil?
    attrs_to_match = [:start_date, :end_date]
    attrs_to_match.all? { |attr| attribute_matches?(attr, other) }
  end

  def attribute_matches?(attribute, other)
    self[attribute] == other[attribute]
  end
end
