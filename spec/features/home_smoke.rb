require 'rails_helper'

feature 'Home Page Smoke Test' do
  it 'should not have asset errors', :js => true do
    visit(root_path)
    expect(page).not_to have_errors
  end
end
