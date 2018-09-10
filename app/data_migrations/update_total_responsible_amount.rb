# Changes the kind field on a policy to "coverall"
require File.join(Rails.root, "lib/mongoid_migration_task")
class UpdateTotalResponsibleAmount < MongoidMigrationTask

  def migrate
    premium_amount_total = ENV['premium_amount_total']
    applied_aptc = ENV['applied_aptc'] 
    employer_contribution= ENV['employer_contribution']   
    total_responsible_amount= ENV['total_responsible_amount']
    eg_id= ENV['eg_id']
    begin
      policy = Policy.where(eg_id: eg_id).first
      if policy.present? && policy.aptc_credits.empty?
        policy.update_attributes!(pre_amt_tot: premium_amount_total) if is_number?(premium_amount_total)
        policy.update_attributes!(applied_aptc: applied_aptc) if is_number?(applied_aptc)
        policy.update_attributes!(employer_contribution: employer_contribution) if is_number?(employer_contribution)
        policy.update_attributes!(tot_res_amt: total_responsible_amount) if is_number?(total_responsible_amount)
        policy.save
        puts "Updated Sucessfully aptc_credits for the eg_id #{eg_id}" unless Rails.env.test?
      else
        raise "Policy not found for eg_id #{ENV['eg_id']} or This policy has aptc credit documents." unless Rails.env.test?
      end
    rescue Exception => e
      puts e.message
    end
  end

  def is_number?(string)
    true if Float(string) rescue false
  end

end 

