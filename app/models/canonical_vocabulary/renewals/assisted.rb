require "spreadsheet"
module CanonicalVocabulary
	module Renewals
		class Assisted < RenewalReport

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
		  
				columns += ia_member_columns(@range) if @range
				@sheet.row(0).concat  columns + IA_POLICY_COLUMNS

				@row = 1
			end
		end
	end
end