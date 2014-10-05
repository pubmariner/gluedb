module Parsers::Xml::Cv
  class Deduction
    include NodeUtils

    TYPE_MAP = {
      "alimony paid" => "alimony_paid",
      "deductible part of self-employment tax" => "deductable_part_of_self_employment_taxes",
      "domestic production activities deduction" => "domestic_production_activities",
      "penalty on early withdrawal of savings" => "penalty_on_early_withdrawel_of_savings",
      "certain business expenses of reservists, performing artists, and fee-basis government officials" => "reservists_performing_artists_and_fee_basis_government_official_expenses",
      "educator expenses" => "educator_expenses",
      "health savings account deduction" => "health_savings_account",
      "moving expenses" => "moving_expenses",
      "rent or royalties" => "rent_or_royalties",
      "self-employed health insurance deduction" => "self_employed_health_insurance",
      "self-employed sep, simple, and qualified plans" => "self_employment_sep_simple_and_qualified_plans"
    }

    FREQUENCY_MAP = {
      "bi-weekly" => "biweekly",
      "half yearly" => "half_yearly",
      "monthly" => "monthly",
      "quarterly" => "quarterly",
      "weekly" => "weekly",
      "yearly" => "yearly"
    }

    def initialize(parser)
      @parser = parser
    end

    def dollar_amount
      @parser.at_xpath('./ns1:amount', NAMESPACES).text.to_f.round(2)
    end

    def type
      data = first_text('./ns1:type')
      data.blank? ? nil : TYPE_MAP[data.downcase]
      TYPE_MAP[@parser.at_xpath('./ns1:type', NAMESPACES).text]
    end

    def frequency
      data = first_text('./ns1:frequency')
      data.blank? ? nil : FREQUENCY_MAP[data.downcase]
    end

    def start_date
      first_date('./ns1:start_date')
    end

    def end_date
      first_date('./ns1:end_date')
    end

    def submitted_date
      first_date('./ns1:submitted_date')
    end

    def amount_in_cents
      (dollar_amount * 100).to_i
    end

    def empty?
      [type,frequency].any?(&:blank?)
    end

    def to_request
      {
        :kind => type,
        :frequency => frequency,
        :start_date => start_date,
        :end_date => end_date,
        :submitted_date => submitted_date,
        :amount_in_cents => amount_in_cents
      }
    end
  end
end
