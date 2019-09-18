module FederalReports
  class ReportUploader

    def self.upload_to_s3(file, bucket_name)
      Aws::S3Storage.save(file, bucket_name, File.basename(file_name), "federal_reports")
    end
  
    def self.publish_to_sftp(file, bucket_name)
      Aws::S3Storage.publish_to_sftp(file, bucket_name, File.basename(file_name))
    end
  
    def self.delete_tax_docs
      File.delete(@pfd_file) if @pfd_file
      File.delete(@xml_file) if @xml_file
    end 
  
    def self.generate_1095A_pdf(params)
      params[:type] = 'new' if params[:type] == 'original'
      @pfd_file = Generators::Reports::IrsYearlySerializer.new(params).generate_notice
    end
    
    def self.generate_h41_xml(params)
      @xml_file = Generators::Reports::IrsYearlySerializer.new(params).generate_h41
    end
    
    
    def self.persist_new_doc
      federal_report = Generators::Reports::Importers::FederalReportIngester.new
      federal_report.federal_report_ingester
    end
    
    def self.upload(params)
      begin
        if generate_1095A_pdf(params) && generate_h41_xml(params)
           [@pfd_file, @xml_file].each do |file|
              upload_to_s3(file, "tax-documents")
              publish_to_sftp(file, "tax-documents")
           end
           persist_new_doc
           delete_tax_docs
           ::PolicyEvents::ReportingEligibilityUpdated.where(status: "processed").delete_all
        else
          raise("File upload failed")
        end
        rescue Exception => e
          puts e.to_s.inspect
        end
      end
    end
  end