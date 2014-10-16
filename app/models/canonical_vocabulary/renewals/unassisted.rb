module CanonicalVocabulary
  module Renewals
    class Unassisted < RenewalReport

      UQHP_PRIMARY_COLUMNS = [
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
        "Incarcerated 1"
      ]

      UQHP_POLICY_COLUMNS = [   
        "Response Date",
        "2014 Health Plan", 
        "2015 Health Plan",
        "2015 Health Plan Premium",
        "2014 Dental Plan", 
        "2015 Dental Plan",
        "2015 Dental Plan Premium"
      ]
      
      attr_accessor :book, :file
      
      def initialize(type="single")
        @report_type = "uqhp"
        
        @file  = "Manual Renewal (#{type.capitalize} UQHP).xls"
        @book  = Spreadsheet::Workbook.new
        @sheet = book.create_worksheet :name => 'Manual Renewal'
        
        columns = UQHP_PRIMARY_COLUMNS
        @range = nil
        @range = 2..MULTIPLE_LIMIT if type == "multiple"
        @range = 2..SUPER_LIMIT if type == "super"
        columns += member_columns(@range) if @range
        @sheet.row(0).concat  columns + UQHP_POLICY_COLUMNS
        @renewal_logger = Logger.new("#{Rails.root}/log/uqhp_renewals.log")
        
        @row = 1
        @row2= 1
      end

      # repeated for each Unassisted Household member
      def member_columns(range)
        range.inject([]) do |columns, n|
          columns += [
            "P#{n} First",
            "P#{n} Last",
            "Age #{n}",
            "Residency #{n}",
            "Citizenship #{n}",
            "Incarcerated #{n}"
          ]
        end
      end
    end
  end
end
