require "rails_helper"

feature "View provider UCAS contact", type: :feature do
  let(:org_ucas_contacts_page) { PageObjects::Page::Organisations::UcasContacts.new }
  let(:admin_contact_page) { PageObjects::Page::Organisations::Contacts::AdminContact.new }
  let(:provider) do
    build :provider,
          provider_code: "A0",
          recruitment_cycle: current_recruitment_cycle
  end
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:provider_params) do
    { "admin_contact" => { "name" => "Updated Name", "email" => "updated@email.com", "telephone" => "12345 678900" } }
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
    visit admin_contact_provider_ucas_contacts_path(provider.provider_code)
  end

  scenario "viewing the admin contact page" do
    visit provider_ucas_contacts_path(provider.provider_code)
    org_ucas_contacts_page.admin_contact_link.click

    expect(current_path).to eq admin_contact_provider_ucas_contacts_path(provider.provider_code)
    expect(admin_contact_page.title).to have_content("UCAS Administrator")
    expect(admin_contact_page.name.value).to eq(provider.admin_contact["name"])
    expect(admin_contact_page.email.value).to eq(provider.admin_contact["email"])
    expect(admin_contact_page.telephone.value).to eq(provider.admin_contact["telephone"])
  end

  scenario "can navigate back to ucas contacts page" do
    click_on "Back"
    expect(org_ucas_contacts_page).to be_displayed
  end

  scenario "updating the admin contact" do
    admin_contact_page.name.set("Updated Name")
    admin_contact_page.email.set("updated@email.com")
    admin_contact_page.telephone.set("12345 678900")
    admin_contact_page.save.click

    expect(current_path).to eq provider_ucas_contacts_path(provider.provider_code)
    expect(org_ucas_contacts_page.flash).to have_content("Your changes have been saved")
  end

  scenario "not ticking permissions box for sharing with ucas" do
    admin_contact_page.name.set("Updated Name")
    admin_contact_page.share_with_ucas_permission.click
    admin_contact_page.save.click

    expect(admin_contact_page).to be_displayed(provider_code: provider.provider_code)
    expect(admin_contact_page).to have_content("Please give permission to share this these details with UCAS")
    expect(admin_contact_page.name.value).to eq("Updated Name")
  end

  scenario "can cancel changes" do
    click_on "Cancel changes"
    expect(org_ucas_contacts_page).to be_displayed
  end
end
