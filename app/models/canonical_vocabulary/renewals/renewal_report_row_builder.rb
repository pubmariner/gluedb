module CanonicalVocabulary
  module Renewals
    class RenewalReportRowBuilder
      attr_reader :data_set
      def initialize(application_group, primary)
        @data_set = []
        @application_group = application_group
        @primary = primary
      end

      def append_integrated_case_number
        @data_set << @application_group.integrated_case
      end

      def append_name_of(member)
        @data_set << member.name_first
        @data_set << member.name_last
      end

      def append_notice_date(notice_date)
        @data_set << notice_date
      end

      def append_household_address
        @data_set << @primary.addresses[0][:address_1]
        @data_set << @primary.addresses[0][:address_2]
        @data_set << @primary.addresses[0][:apt]
        @data_set << @primary.addresses[0][:city]
        @data_set << @primary.addresses[0][:state]
        @data_set << @primary.addresses[0][:postal_code]
      end

      def append_aptc
        append_blank 
      end

      def append_response_date(response_date)
        @data_set << response_date
      end

      def append_policy(policy)
        @data_set << (policy.current.nil? ? nil : policy.current[:plan])
        @data_set << policy.future_plan_name
        @data_set << policy.quoted_premium
      end

      def append_post_aptc_premium
        append_blank  
      end

      def append_financials
        @data_set << @application_group.yearly_income("2014")
        append_blank 
        @data_set << @application_group.irs_consent
      end

      def append_age_of(member)
        @data_set << member.age
      end

      def append_residency_of(member)
        @data_set << residency(member)
      end

      def append_citizenship_of(member)
        @data_set << member.citizenship
      end

      def append_tax_status_of(member)
        @data_set << member.tax_status
      end

      def append_mec_of(member)
        @data_set << member.mec
      end

      def append_app_group_size
        @data_set << @application_group.size
      end

      def append_yearwise_income_of(member)
        @data_set << member.yearwise_incomes("2014")
      end

      def append_blank
        @data_set << nil
      end

      def append_incarcerated(member)
        @data_set << member.incarcerated
      end

      private 

      def residency(member)
        return member.residency unless member.residency.blank?
        return "No Status" if @primary.addresses[0].nil?
        @primary.addresses[0][:state].strip == "DC" ? "D.C. Resident" : "Not a D.C Resident"
      end
    end
  end
end
