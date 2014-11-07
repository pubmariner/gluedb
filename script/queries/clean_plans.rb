plans = Plan.where(year: 2014).no_timeout

plans.each do |plan|
  plan.premium_tables = plan.premium_tables.reject do |pt|
    pt.rate_start_date.year == 2015
  end

  plan.save!
end

