module Protocols
  module Dcas
    class EmployerGroupFile

      XML_NSES = {
        "de" => "http://dchealthlink.com/vocabulary/20131030/employer"
      }

      PlanGroup = Struct.new(:hios_id, :coverage_type, :original_effective_date) do
        def to_model
          plan = Plan.find_by_hios_id(self.hios_id)
          raise self.hios_id.inspect if plan.nil?
          ElectedPlan.new(
            :carrier => plan.carrier,
            :qhp_id => self.hios_id,
            :coverage_type => self.coverage_type,
            :metal_level => plan.metal_level,
            :hbx_plan_id => plan.hbx_plan_id,
            :original_effective_date => self.original_effective_date
          )
        end
      end

      EmployerRec = Struct.new(:name, :fein, :hbx_id, :plan_groups) do
        def to_model
          emp = Employer.new(
            :hbx_id => self.hbx_id,
            :fein => self.fein,
            :name => self.name
          )
          self.plan_groups.each do |pg|
            emp.elected_plans << pg.to_model
          end
          emp
        end
      end

      def initialize(xml_str)
        @xml = Nokogiri::XML(xml_str)
        @employers = process_employers(@xml)
      end

      def persist!
        @employers.each do |emp|
          Employer.create_from_group_file(emp.to_model)
        end
      end

      def process_employers(xml)
        xml.xpath("//de:employer", XML_NSES).map do |node|
          rec = EmployerRec.new(
            node.xpath("de:name", XML_NSES).first.text,
            node.xpath("de:fein", XML_NSES).first.text,
            node.xpath("de:employer_exchange_id", XML_NSES).first.text,
            []
          )
          pgs = node.xpath("de:plans/de:plan", XML_NSES).map do |pnode|
            PlanGroup.new(
              pnode.xpath("de:qhp_id", XML_NSES).first.text,
              pnode.xpath("de:coverage_type", XML_NSES).first.text,
              pnode.xpath("de:original_effective_date", XML_NSES).first.text,
            )
          end
          rec.plan_groups = pgs
          rec
        end
      end
    end
  end
end
