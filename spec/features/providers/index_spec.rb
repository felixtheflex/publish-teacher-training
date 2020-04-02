require "rails_helper"

feature "View providers", type: :feature do
  let(:organisation_page) { PageObjects::Page::Organisations::OrganisationPage.new }
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:provider_1) { build :provider, provider_code: "A0", include_counts: [:courses] }
  let(:rollover) { false }

  before do
    stub_omniauth
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}",
      current_recruitment_cycle.to_jsonapi,
    )
    allow(Settings).to receive(:rollover).and_return(rollover)
  end

  context "with two providers" do
    let(:provider_2) { build :provider, provider_code: "A1", include_counts: [:courses] }
    let(:provider_response) { provider_1.to_jsonapi(include: %i[courses accrediting_provider]) }

    scenario "Navigate to /organisations" do
      stub_api_v2_request(
        "/recruitment_cycles/#{current_recruitment_cycle.year}" \
        "/providers",
        resource_list_to_jsonapi([provider_1, provider_2]),
      )

      visit providers_path
      expect(find("h1")).to have_content("Organisations")
      expect(first(".govuk-list li")).to have_content(provider_1.provider_name.to_s)
    end

    scenario "Navigate to /organisations/A0" do
      stub_api_v2_request(
        "/recruitment_cycles/#{current_recruitment_cycle.year}" \
        "/providers/#{provider_1.provider_code}",
        provider_response,
      )

      visit provider_path(provider_1.provider_code)
      expect(find("h1")).to have_content(provider_1.provider_name.to_s)
      expect(organisation_page).not_to have_selector(".govuk-breadcrumbs")

      expect(organisation_page).not_to have_current_cycle
      expect(organisation_page).not_to have_next_cycle

      expect(organisation_page).to have_link("Locations", href: "/organisations/A0/#{Settings.current_cycle}/locations")
      expect(organisation_page).to have_link("Courses", href: "/organisations/A0/#{Settings.current_cycle}/courses")
      expect(organisation_page).to have_link("UCAS contacts", href: "/organisations/A0/ucas-contacts")
    end

    context "Rollover" do
      let(:rollover) { true }

      scenario "Navigate to /organisations/A0" do
        stub_api_v2_request(
          "/recruitment_cycles/#{current_recruitment_cycle.year}" \
          "/providers/#{provider_1.provider_code}",
          provider_response,
        )

        visit provider_path(provider_1.provider_code)
        expect(find("h1")).to have_content(provider_1.provider_name.to_s)
        expect(organisation_page).to have_current_cycle
        expect(organisation_page).to have_next_cycle
      end
    end
  end

  context "with more than ten providers" do
    let(:provider_2) { build :provider, provider_code: "A1", include_counts: [:courses] }

    it "displays pagination navigation" do
      providers = []

      26.times do
        providers << build(:provider, provider_code: "A1", include_counts: [:courses])
      end

      stub_api_v2_request(
        "/recruitment_cycles/#{current_recruitment_cycle.year}" \
        "/providers",
        resource_list_to_jsonapi(providers),
        )

      visit providers_path

      expect(find(".pub-c-pagination__link-title")).to have_content("Next page")
    end
  end

  context "with no providers" do
    let(:no_providers_page) { PageObjects::Page::Organisations::NoProviders.new }
    let(:forbidden_page) { PageObjects::Page::Forbidden.new }

    scenario "Navigate to /organisations" do
      stub_api_v2_request(
        "/recruitment_cycles/#{current_recruitment_cycle.year}" \
        "/providers",
        resource_list_to_jsonapi([]),
      )

      visit providers_path
      expect(no_providers_page.no_providers_text).to be_visible
    end

    scenario "Navigate to /organisations/A0" do
      stub_api_v2_request(
        "/recruitment_cycles/#{current_recruitment_cycle.year}" \
        "/providers/#{provider_1.provider_code}",
        "",
        :get,
        403,
      )

      visit provider_path(provider_1.provider_code)
      expect(forbidden_page.forbidden_text).to be_visible
    end
  end
end
