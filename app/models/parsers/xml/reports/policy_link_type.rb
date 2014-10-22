module Parsers::Xml::Reports
  class PolicyLinkType

    def initialize(policy)
      @policy = policy
    end

    def id
      @policy.at_xpath("n1:id").text
    end

    def individual?
      @policy.at_xpath("n1:employer").nil? ? true : false
    end

    def begin_date
      node = @policy.at_xpath("n1:enrollees/n1:enrollee/n1:begin_date")
      node.nil? ? nil : date_formatter(node.text)
    end

    def end_date
      node = @policy.at_xpath("n1:enrollees/n1:enrollee/n1:end_date")
      node.nil? ? nil : date_formatter(node.text)
    end

    def active?
      return false if begin_date == end_date
      (begin_date < renewal_start && (end_date.nil? || end_date >= renewal_start)) ? true : false
    end

    private

    def date_formatter(date)
      Date.strptime(date, '%Y%m%d')
    end

    def renewal_start
      Date.parse("2015-1-1")
    end
  end
end