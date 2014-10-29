module Parsers
  module Edi
    class ImportCache
      def initialize
        @hios_cache = Plan.all.inject({}) do |acc, p|
          acc[p.hios_plan_id] = p
          acc
        end
        @carrier_fein_cache = Carrier.all.inject({}) do |acc, c|
          c.carrier_profiles.each do |c_prof|
            acc[c_prof.fein] = c
          end
          acc
        end
      end

      def lookup_hios(h_id)
        @hios_cache[h_id]
      end

      def lookup_carrier_fein(c_fein)
        @carrier_fein_cache[c_fein]
      end
    end
  end
end
