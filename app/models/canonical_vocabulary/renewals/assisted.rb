require "spreadsheet"
module CanonicalVocabulary
  module Renewals
    class Assisted < RenewalReport

      IA_PRIMARY_COLUMNS = [
        "IC Number",
        "Date of Notice", 
        "Primary First",
        "Primary Last",
        "Primary Street 1",
        "Primary Street 2",
        "Apt",
        "City",
        "State",
        "Zip",
        "Age 1",
        "Residency 1",
        "Citizenship 1",  
        "Tax Status 1",
        "MEC 1",
        "HH Size 1",
        "Projected Income 1",
        "Incarcerated 1"
      ]

      IA_POLICY_COLUMNS = [   
        "APTC",
        "Response Date",
        "2014 Health Plan", 
        "2015 Health Plan",
        "2015 Health Plan Premium",
        "HP Premium After APTC",
        "2014 Dental Plan", 
        "2015 Dental Plan",
        "2015 Dental Plan Premium",
        "HH Total Income",  
        "CSR Eligibility",
        "IRS Consent"
      ]
      
      attr_accessor :book, :file
      
      def initialize(type="single")
        @report_type = "ia"
        
        @file  = "Manual Renewal (#{type.capitalize} IA).xls"
        @book  = Spreadsheet::Workbook.new
        @sheet = book.create_worksheet :name => 'Manual Renewal'
        
        columns = IA_PRIMARY_COLUMNS
        @range = nil
        @range = 2..MULTIPLE_LIMIT if type == "multiple"
        @range = 2..SUPER_LIMIT if type == "super"
        
        columns += member_columns(@range) if @range
        @sheet.row(0).concat  columns + IA_POLICY_COLUMNS
        
        @renewal_logger = Logger.new("#{Rails.root}/log/ia_renewals_internal.log")        
        @row = 1
      end

      # Repeated for each IA household member
      def member_columns(range)
        range.inject([]) do |columns, n|
          columns += [
            "P#{n} First",
            "P#{n} Last",
            "Age #{n}",
            "Residency #{n}",
            "Citizenship #{n}",
            "Tax Status #{n}",
            "MEC #{n}",
            "HH Size #{n}",
            "Projected Income #{n}",
            "Incarcerated #{n}"
          ]
        end
      end
    end
  end
end
