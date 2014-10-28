require 'rails_helper'

describe DashboardsController do
  login_user

  describe 'GET index' do
    it "should have a table of transactions" do
      get :index
      expect(assigns( :transactions )).not_to be_nil
    end
  end
end
