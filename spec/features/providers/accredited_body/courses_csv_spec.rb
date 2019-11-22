require "rails_helper"

feature "Download accredited body courses CSV", type: :feature do
  let(:provider) do
    build :provider,
          provider_code: "A0",
          content_status: "published"
  end

  scenario "viewing organisation about page" do
    visit provider_accredited_body_courses_path(provider.provider_code, provider.recruitment_cycle.year)
    expect(current_path).to eq provider_accredited_body_courses_path(provider.provider_code, provider.recruitment_cycle.year)
  end
end
