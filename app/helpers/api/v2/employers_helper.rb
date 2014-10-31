module Api::V2::EmployersHelper
  def build_carrier_cache
    Carrier.all.inject({}) do |acc, c|
      acc[c.id] = c
      acc
    end
  end
end
