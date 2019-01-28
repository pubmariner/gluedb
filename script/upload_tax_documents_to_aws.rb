# rails runner script/upload_tax_documents_to_aws.rb 'folder_path' -e production

folder_path = ARGV[0]

if File.directory?(folder_path)
  raise "No directory exists with the given name: #{folder_path}"
elsif Dir.entries(folder_path).size < 1
  raise "Unable to find files/folders in the given path: #{folder_path}"
end

field_names  = %w(uploaded_file_name)

def upload_to_s3(file_name, csv)
  base_name = File.basename(file_name)
  Aws::S3Storage.save(file_name, "tax-documents", base_name)
  @counter += 1
  csv << [
    base_name
  ]
end

def process_folder(folder, csv)
  Dir.entries(folder).each do |file|
    next unless File.file?(file)
    upload_to_s3(file, csv)
  end
end

file_name = "#{Rails.root}/upload_tax_documents_to_aws_#{Time.now.strftime('%m_%d_%Y')}.csv"

CSV.open(file_name, "w", force_quotes: true) do |csv|
  @counter = 0
  csv << field_names

  Dir.entries(folder_path).each do |folder|
    next if folder == '.' or folder == '..'
    begin
      next unless File.directory?(folder)
      process_folder(folder, csv)
    rescue => e
      puts 'Unable to process file or folder, error reason: #{e.backtrace}' unless Rails.env.test?
    end
  end
  puts 'Uploaded #{@counter} number of pdfs to S3' unless Rails.env.test?
end
