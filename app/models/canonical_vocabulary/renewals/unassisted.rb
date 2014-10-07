module CanonicalVocabulary
	module Renewals
		class Unassisted < RenewalReport

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
				columns += uqhp_member_columns(@range) if @range
				@sheet.row(0).concat  columns + UQHP_POLICY_COLUMNS
				@renewal_logger = Logger.new("#{Rails.root}/log/uqhp_renewals.log")

				@row = 1
				@row2=1
			end
		end
	end
end
