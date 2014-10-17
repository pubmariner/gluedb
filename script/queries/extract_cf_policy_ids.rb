require 'csv'

plan_ids = Plan.all.inject({}) do |h, plan|
  h[plan.hios_plan_id] = plan.id
  h
end

ok_records = 0
  CSV.open('cf_with_pol_id.csv', 'w') do |out_csv|
    out_csv << [
      'policy_hbx_id',
      'status','begin_date','end_date','enrolled_count',
      'subscriber_last_name','subscriber_first_name','subscriber_middle_name','subscriber_hbx_id',
      'hios_plan_id','glue_policy_id','policy_lookup_result'
    ]
    CSV.foreach("cf_latest_with_eg.csv", :headers => true) do |inrow|
      fs = inrow.fields
      data = inrow.to_hash
      eg_id = data['policy_hbx_id']
      if eg_id.blank?
        out_csv << fs + [nil, "blank policy id"]
      else
        hios_id = data['hios_plan_id'].strip
        plan_id = plan_ids[hios_id]
        pols = Policy.where({
          :plan_id => plan_id,
          :eg_id => eg_id.strip,
          :employer_id => nil
        })
        the_count = pols.count

        if the_count == 0
          out_csv << fs + [nil, "no matching policy"]
        elsif the_count == 1
          out_csv << (fs + [pols.first.id, "success"])
          ok_records = ok_records + 1
        else
          out_csv << fs + [nil, "too many policies: #{the_count}"]
        end
      end
    end
end

puts ok_records.to_s
