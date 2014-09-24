require 'csv'

=begin
policy_ids = Protocols::X12::TransactionSetHeader.collection.aggregate(
  {"$match" => {"transaction_kind" => "effectuation", "_type"=>"Protocols::X12::TransactionSetEnrollment"}},
  {"$group" => {"_id" => "$policy_id"}}
).map { |r| r["_id"] }.uniq

dental_plan_ids = Plan.where({"coverage_type" => "dental"}).map(&:id).map { |tid| Moped::BSON::ObjectId.from_string(tid) }
=end
policies = Policy.where

def bad_eg_id(eg_id)
 (eg_id =~ /\A000/) || (eg_id =~ /\+/)
end

CSV.open("steven_report.csv", 'w') do |csv|
  csv << ["Enrollment Group ID", "Plan HIOS ID", "Enrollment Type", "Plan Name", "Carrier Name", "HBX Id", "First", "Middle", "Last", "DOB", "SSN"]
  policies.each do |pol|
    if !bad_eg_id(pol.eg_id)
      if !pol.subscriber.nil?
        if !pol.subscriber.cancelled?
          pol.enrollees.each do |en|
            per = en.person
            csv << [pol.eg_id, pol.plan.hios_plan_id, (pol.employer_id.nil? ? "QHP" : "SHOP"), pol.plan.name, pol.carrier.name, en.m_id, per.name_first, per.name_middle, per.name_last, en.member.dob.strftime("%Y%m%d"), en.member.ssn]
          end
        end
      end
    end
  end
end
