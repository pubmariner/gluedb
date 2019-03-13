load Rails.root.to_s + '/lib/tasks/change_enrollee_member_id.rake'
require File.join(Rails.root, "lib/mongoid_migration_task")

class MassChangeEnrolleeMemberIdsFromCSV < MongoidMigrationTask
  def migrate
    csv_file = ENV['csv_filename']
    if csv_file.present?
    else
      puts("No CSV file present.") unless Rails.env.test?
    end
  end

  def execute_change_enrollee_member_ids(csv_file)
    CSV.read(csv_file).each do |row|
      # Skips the header Row
      next if CSV.read(csv_file)[0] == row
      # Removes nil values (blank cells) from row array
      row = row.compact
      # Skips entirely blank rows
      next if row.length == 0
      # Authority HBX id row[0]
      # Non Authority member ID should be row[1]
      ENV['eg_id'] = Policy.where("enrollees.m_id" => row[0]).first.eg_id
      ENV['old_hbx_id'] = row[1]
      ENV['new_hbx_id'] = row[0]
      Rake::Task['migrations:change_enrollee_member_id'].execute
      end
    end    
  end
  end
end
