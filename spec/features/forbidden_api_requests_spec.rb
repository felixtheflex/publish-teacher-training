require "rails_helper"

feature "Handling Forbidden responses from the backend", type: :feature do
  let(:forbidden_page) { PageObjects::Page::Forbidden.new }

  before do
    stub_omniauth
    stub_api_v2_request("/recruitment_cycles/#{Settings.current_cycle}", "", :get, 403)
  end

  it "Does not redirect the page" do
    visit "/organisations/A0/"
    expect(page.current_path).to eq("/organisations/A0")
  end

  it "Renders the forbidden page" do
    visit "/organisations/A0/"
    expect(forbidden_page.forbidden_text).to be_visible
  end
end
