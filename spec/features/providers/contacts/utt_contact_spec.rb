require "rails_helper"

feature "View provider UCAS contact", type: :feature do
  let(:org_ucas_contacts_page) { PageObjects::Page::Organisations::UcasContacts.new }
  let(:utt_contact_page) { PageObjects::Page::Organisations::Contacts::UTTContact.new }
  let(:provider) do
    build :provider,
          provider_code: "A0",
          recruitment_cycle: current_recruitment_cycle
  end
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:provider_params) do
    { "utt_contact" => { "name" => "Updated Name", "email" => "updated@email.com", "telephone" => "12345 678900" } }
  end

  before do
    stub_omniauth
    stub_api_v2_resource(provider)
    stub_api_v2_request(
      "/recruitment_cycles/#{provider.recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}",
      "", :patch, 200
    ).with(body: {
      data: {
        provider_code: provider.provider_code,
        type: "providers",
        attributes: provider_params,
      },
    }.to_json)
    visit utt_contact_provider_ucas_contacts_path(provider.provider_code)
  end

  scenario "viewing the utt contact page" do
    visit provider_ucas_contacts_path(provider.provider_code)
    org_ucas_contacts_page.utt_contact_link.click

    expect(current_path).to eq utt_contact_provider_ucas_contacts_path(provider.provider_code)
    expect(utt_contact_page.title).to have_content("UCAS Teacher Training (UTT) correspondent")
    expect(utt_contact_page.name.value).to eq(provider.utt_contact["name"])
    expect(utt_contact_page.email.value).to eq(provider.utt_contact["email"])
    expect(utt_contact_page.telephone.value).to eq(provider.utt_contact["telephone"])
  end

  scenario "can navigate back to ucas contacts page" do
    click_on "Back"
    expect(org_ucas_contacts_page).to be_displayed
  end

  scenario "updating the UTT contact" do
    utt_contact_page.name.set("Updated Name")
    utt_contact_page.email.set("updated@email.com")
    utt_contact_page.telephone.set("12345 678900")
    utt_contact_page.save.click

    expect(current_path).to eq provider_ucas_contacts_path(provider.provider_code)
    expect(org_ucas_contacts_page.flash).to have_content("Your changes have been saved")
  end
  #
  scenario "not ticking permissions box for sharing with ucas" do
    utt_contact_page.name.set("Updated Name")
    utt_contact_page.share_with_ucas_permission.click
    utt_contact_page.save.click

    expect(utt_contact_page).to be_displayed(provider_code: provider.provider_code)
    expect(utt_contact_page).to have_content("Please give permission to share this these details with UCAS")
    expect(utt_contact_page.name.value).to eq("Updated Name")
  end

  scenario "can cancel changes" do
    click_on "Cancel changes"
    expect(org_ucas_contacts_page).to be_displayed
  end
end
