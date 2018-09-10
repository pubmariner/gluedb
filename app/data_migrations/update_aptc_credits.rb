require File.join(Rails.root, "lib/mongoid_migration_task")

class UpdateAptcCredits < MongoidMigrationTask

  def migrate 
    
    start_on = ENV['start_on']
    pre_amt_tot = ENV['pre_amt_tot']
    tot_res_amt = ENV['tot_res_amt'] 
    aptc = ENV['aptc']
    policy = Policy.where(eg_id: ENV['eg_id']).first
    
    unless policy.present?
      raise  "Could not find a policy with the id #{ENV['eg_id']}"
    end

    credit = policy.aptc_credits.where(start_on: start_on).first 
    if credit
      credit.update_attributes!(pre_amt_tot: pre_amt_tot) if is_number?(pre_amt_tot)
      credit.update_attributes!(tot_res_amt: tot_res_amt) if is_number?(tot_res_amt)
      credit.update_attributes!(aptc: aptc) if is_number?(aptc)
      puts "APTC credit has been updated to pre_amt_tot: #{credit.pre_amt_tot}, tot_res_amt #{credit.tot_res_amt}, aptc amount: #{credit.aptc}" unless Rails.env.test?
    else  
      puts "There are no matching aptc credits with that start date" unless Rails.env.test?
    end
  end

  def is_number?(string)
    true if Float(string) rescue false
  end


end