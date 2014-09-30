class ExposesPlanXml
  def initialize(parser)
    @parser = parser
  end

  def qhp_id
    @parser.at_css('qhp_id').text
  end

  def plan_exchange_id
    @parser.at_css('plan_exchange_id').text
  end

  def carrier_id
    @parser.at_css('carrier_id').text
  end

  def carrier_name
    @parser.at_css('carrier_name').text
  end

  def name
    @parser.at_css('plan_name').text
  end

  def coverage_type
    @parser.at_css('coverage_type').text
  end

  def original_effective_date
    @parser.at_css('original_effective_date').text
  end

  def group_id
    node = @parser.at_css('group_id')
    (node.nil?) ? nil : node.text
  end

  def metal_level_code
    @parser.at_css('metal_level_code').text
  end

  def policy_number
    node = @parser.at_css('policy_number')
    (node.nil?) ? '' : node.text
  end
end
