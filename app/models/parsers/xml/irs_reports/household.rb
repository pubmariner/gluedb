require 'net/http'

module Parsers::Xml::IrsReports
  class Household
    
    def initialize(data_xml = nil)      
      # parser = File.open(Rails.root.to_s + "/households.xml")
      # parser = Nokogiri::XML(parser)
      @root = data_xml #.root
      # @root = parser.root
    end

    def primary
      @root.at_xpath("n1:head_of_household/n1:id").text 
    end

    def spouse
      members.select{|k,v| v == 'spouse'}
    end

    def dependents
      members.reject{|k,v| v == 'spouse'}
    end

    def root
      @root
    end

    def members
      members = {}
      @root.xpath("n1:household_members/n1:household_member").each do |ele|
        member_id = ele.at_xpath("n1:id").text
        if members.has_value?("spouse")
          relation = "dependent"
        else
          relationships = []
          ele.xpath("n1:relationships/n1:relationship").each do |ele|
            relationships << ele.at_xpath("n1:relationship_uri").text.split(/#/)[1]
          end
          relation = relationships.include?("spouse") ? "spouse" : "dependent"
        end
        members[member_id] = relation
      end
      members
    end

    def all_members
      ([] << primary) + spouse.keys + dependents.keys
    end

    def hh_size
      all_members.compact.size
    end

    def member_policy_ids(app_group)
      policies = []
      all_members.each do |member|
        policies << app_group.individual_policy_holders[member]
      end

      policy_ids = []
      policies.flatten.uniq.each do |policy|
        if app_group.individual_policies.include?(policy)
          policy_ids << policy.match(/\d+$/)[0]
        end
      end

      policy_ids
    end

    def member_ids
      all_members.map{|x| x.match(/\w+$/)[0]}
    end
  end
end
