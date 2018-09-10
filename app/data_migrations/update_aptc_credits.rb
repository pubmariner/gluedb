require File.join(Rails.root, "lib/mongoid_migration_task")

class UpdateAptcCredits < MongoidMigrationTask

  def migrate 
    policy = Policy.where(eg_id: ENV['eg_id']).first
    start_on = ENV['start_on']
    pre_amt_tot = ENV['pre_amt_tot'] 
    tot_res_amt = ENV['tot_res_amt']
 
    if policy 
      credit = policy.aptc_credits.where(start_on: start_on).first 
      if credit
        if is_number?(tot_res_amt) && is_number?(pre_amt_tot)
            credit.update_attributes!(pre_amt_tot: pre_amt_tot)
            credit.update_attributes!(tot_res_amt: tot_res_amt)
            puts "Premuim amount and total responsible amount has been updated to #{credit.pre_amt_tot} and #{credit.tot_res_amt} respectively"
        else  
          puts "missing a valid number"
        end
      else  
        puts "There are no matching aptc credits for this policy" unless Rails.env.test?
      end
    else 
      puts "Could not find a policy with the id #{ENV['eg_id']}"  unless Rails.env.test?
    end
  end

  def is_number?(string)
    true if Float(string) rescue false
  end


end