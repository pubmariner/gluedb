class ToolsController < ApplicationController
  def premium_calc
    @carriers = Carrier.by_name
  end

end
