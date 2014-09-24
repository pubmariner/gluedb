require 'csv'

people = []

CSV.open('brokers_with_glue_data_20140919.csv', 'w') do |csv|
  csv << ["PROVIDERTYPE",  "PROVIDERPRACTICEBUSINESSAREA" , "PROVIDERREFERENCENUMBER", "NATIONALPRODUCERNUMBER", "PROVIDERNAME", "CLIENT_NAME", "SSN", "DOB", "USER_ACCOUNT", "PROVIDERSTATUS", "STARTDATE", "ENDDATE",
          "CARRIERINGLUE", "BROKERINGLUE", "SHOP"]

#  csv << [
#    "NATIONALPRODUCERNUMBER","PROVIDERNAME","CLIENT_NAME","SSN","DOB","USER_ACCOUNT","PROVIDERSTATUS","STARTDATE","ENDDATE","CARRIERINGLUE","BROKERINGLUE", "SHOP"
#  ]
  CSV.foreach("script/queries/brokers_from_curam.csv", :headers => true)do |inrow|
    row_a = inrow.fields
    row_h = inrow.to_hash
    if row_h['SSN'].blank?
      csv << (row_a + ["NO SSN"])
    elsif row_h['SSN'].strip == '#N/A'
      csv << (row_a + ["NO SSN"])
    else
      per = Person.where({
        "members" => { 
          "$elemMatch" => {
            "ssn" => 
            row_h['SSN'].strip
          }
        }}).first
        if !per.blank?
          pol_vals = per.policies.map do |pol|
            [pol.carrier.name, pol.broker.nil? ? "" : pol.broker.name_full, 
              pol.employer_id.blank? ? "N" : "Y"
            ]
          end
          pol_vals.uniq.each do |pval|
            csv << row_a + pval
          end
        else
          csv << row_a + ["NOT IN GLUE"]
        end
    end
  end
end
