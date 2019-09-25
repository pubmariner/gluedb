module FederalReports
  class ReportUploader

    def upload_1095(pdf_file, bucket_name)
      Aws::S3Storage.save(pdf_file, bucket_name, File.basename(pdf_file))
    end
    
    def upload_h41(xml_file, bucket_name)
      s3_result = Aws::S3Storage.save(xml_file, bucket_name, File.basename(xml_file), "h41")
      Aws::S3Storage.publish_to_sftp(xml_file, bucket_name, s3_result[:uri])
      ExternalEvents::ExternalFederalReportingNotification.notify(s3_result, @policy)
    end
  
    def remove_tax_docs
      FileUtils.rm_rf("#{Rails.root}/H41_federal_report") 
      FileUtils.rm_rf("#{Rails.root}/tmp/irs_notices")
      base_name =  File.basename(@xml_file, ".zip")  
      File.delete(base_name) if File.exists?(base_name)
      File.delete(@pdf_file) if File.exists?(@pdf_file)
      File.delete(@xml_file) if File.exists?(@xml_file)
    end 
  
    def generate_1095A_pdf(params)
      params[:type] = 'new' if params[:type] == 'original'
      @pdf_file = Generators::Reports::IrsYearlySerializer.new(params).generate_notice
    end
    
    def generate_h41_xml(params)
      @xml_file = Generators::Reports::IrsYearlySerializer.new(params).generate_h41
    end
    
    def persist_new_doc
      federal_report = Generators::Reports::Importers::FederalReportIngester.new
      federal_report.federal_report_ingester
    end
    
    def upload(params)
      @policy = Policy.find(params[:policy_id])
      begin
          generate_1095A_pdf(params)
          generate_h41_xml(params)
          upload_1095(@pdf_file, "tax-documents")
          upload_h41(@xml_file, "tax-documents")
          persist_new_doc
          remove_tax_docs
          ::PolicyEvents::ReportingEligibilityUpdated.where(status: "processed").delete_all
        rescue Exception => e
          raise FederalReports::ReportUploadError.new(params[:policy_id], e.message)
        end
      end
    end
  end