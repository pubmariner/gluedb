require 'ostruct'

module Generators::Reports 
  class SbmiPolicyBuilder
    include MoneyMath

    attr_accessor :sbmi_policy, :policy

    def initialize(policy)
      @sbmi_policy = PdfTemplates::SbmiPolicy.new
      @policy_disposition = PolicyDisposition.new(policy)
      @policy = policy
      @carrier_hash = {}
    end

    def process
      append_policy_information
      append_coverage_household
      append_financial_information_loops
    end

    def append_policy_information
      sbmi_policy.record_control_number = policy.id
      sbmi_policy.qhp_id = policy.plan.hios_plan_id.split('-').first
      sbmi_policy.exchange_policy_id = policy.eg_id 
      sbmi_policy.exchange_subscriber_id = policy.subscriber.m_id
      sbmi_policy.coverage_start = format_date(policy.policy_start)
      sbmi_policy.coverage_end = format_date(policy.policy_end)
      if policy.canceled?
        sbmi_policy.effectuation_status = 'N'
      else
        sbmi_policy.effectuation_status = 'Y'
      end
      sbmi_policy.insurance_line_code = (policy.plan.coverage_type =~ /health/i ? 'HLT' : 'DEN')
    end

    def append_coverage_household
      if policy.canceled?
        if policy.enrollees.any? { |e| !e.canceled?}
          raise "Canceled policy has enrollee with improper start and end dates"
        end
        policy.enrollees.each{|enrollee| append_covered_individual(enrollee, (enrollee.subscriber? ? 'Y' : 'N'))}
      else
        enrollees = policy.enrollees.reject { |e| e.canceled?}
        # if policy.has_responsible_person?
        #   append_covered_individual(policy.responsible_person, true)
        #   enrollees.each{|enrollee| append_covered_individual(enrollee, 'N') }
        # else
        enrollees.each{|enrollee| append_covered_individual(enrollee, (enrollee.subscriber? ? 'Y' : 'N'))}
      end
    end

    def append_covered_individual(enrollee, is_subscriber)
      if enrollee.is_a?(Person)
        coverage_start = policy.policy_start
        coverage_end = policy.policy_end
        person = enrollee
      else
        person = enrollee.person
      end
      
      member = person.authority_member

      if is_subscriber == "Y"
        @subscriber_zipcode = postal_code(person)
      end

      if @subscriber_zipcode.blank?
        raise "Zip code missing!!"
      end

      sbmi_policy.coverage_household << PdfTemplates::SbmiEnrollee.new({
        exchange_assigned_memberId: member.hbx_member_id,
        subscriber_indicator: is_subscriber,
        person_last_name: person.name_last,
        person_first_name: person.name_first,
        person_middle_name: person.name_middle,
        person_name_suffix: person.name_sfx,
        birth_date: format_date(member.dob),
        social_security_number: member.ssn,
        gender_code: (member.gender == "male" ? 'M' : (member.gender == "female" ? 'F' : 'U')),
        postal_code: (postal_code(person) || @subscriber_zipcode),
        # non_covered_subscriberInd: (enrollee.is_a?(Person) ? 'Y' : 'N'),
        member_start_date: format_date(coverage_start || enrollee.coverage_start),
        member_end_date: format_date(coverage_end || enrollee.coverage_end)
      })
    end

    def append_financial_information_loops
      financial_information_loops.each do |financial_dates|
        sbmi_policy.financial_loops << append_financial_information(financial_dates)
      end
    end

    def append_financial_information(financial_dates)

      total_premium = @policy_disposition.as_of(financial_dates[0]).pre_amt_tot
      applied_aptc = @policy_disposition.as_of(financial_dates[0]).applied_aptc
      responsible_amount = @policy_disposition.as_of(financial_dates[0]).tot_res_amt

      financial_info = PdfTemplates::FinancialInformation.new({
        financial_effective_start_date: format_date(financial_dates[0]),
        financial_effective_end_date: format_date(financial_dates[1]),
        monthly_premium_amount: total_premium,
        monthly_responsible_amount: responsible_amount,
        monthly_aptc_amount: applied_aptc,
        csr_variant: csr_variant
      })

      if mid_month_start_date?(financial_dates)
        multiplying_factor = ((financial_dates[0].end_of_month.day.to_f - financial_dates[0].day.to_f + 1.0) / financial_dates[0].end_of_month.day)

        financial_info.prorated_amounts << PdfTemplates::ProratedAmount.new({
          partial_month_premium: as_dollars(multiplying_factor * total_premium),
          partial_month_aptc: as_dollars(multiplying_factor * applied_aptc),
          partial_month_start_date: format_date(financial_dates[0]),
          partial_month_end_date: format_date(financial_dates[0].end_of_month)
        })
      end

      if mid_month_end_date?(financial_dates)
        multiplying_factor = (financial_dates[1].day.to_f / financial_dates[1].end_of_month.day)

        financial_info.prorated_amounts << PdfTemplates::ProratedAmount.new({
          partial_month_premium: as_dollars(multiplying_factor * total_premium),
          partial_month_aptc: as_dollars(multiplying_factor * applied_aptc),
          partial_month_start_date: format_date(financial_dates[1].beginning_of_month),
          partial_month_end_date: format_date(financial_dates[1])
        })
      end

      financial_info
    end

    private

    def financial_information_loops
      active_enrollees = policy.enrollees.reject { |e| e.canceled?}

      loop_start_dates = [policy.policy_start]
      active_enrollees.each do |enrollee|
        if enrollee.coverage_start != policy.policy_start
          loop_start_dates << enrollee.coverage_start
        end
        if enrollee.coverage_end.present? && (enrollee.coverage_end != policy.policy_end)
          loop_start_dates << enrollee.coverage_end.next_day
        end
      end

      loop_start_dates = loop_start_dates.uniq.sort
      loop_start_dates.inject([]) do |loops, start_date|
        next_start_date = loop_start_dates.index(start_date) + 1
        end_date = loop_start_dates[next_start_date].prev_day if loop_start_dates[next_start_date].present?
        loops << [start_date, (end_date || policy.policy_end)]
      end
    end

    def mid_month_start_date?(financial_dates)
      coverage_period_start = financial_dates[0]
      coverage_period_start.beginning_of_month != coverage_period_start
    end

    def mid_month_end_date?(financial_dates)
      coverage_period_end = financial_dates[1]
      coverage_period_end.present? && (coverage_period_end.end_of_month != coverage_period_end)
    end  

    def csr_variant
      if policy.plan.coverage_type =~ /health/i
        policy.plan.hios_plan_id.split('-').last
      else
        '01' # Dental always 01
      end
    end

    def postal_code(person)
      address = person.home_address || person.mailing_address
      address.present? ? address.zip : nil
    end

    def format_date(date)
      date = policy.policy_start.end_of_year if date.blank?
      date.strftime("%Y-%m-%d")
    end
  end
end
