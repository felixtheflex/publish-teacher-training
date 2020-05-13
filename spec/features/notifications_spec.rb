require "rails_helper"

feature "Notifications", type: :feature do
  let(:organisation_show_page) { PageObjects::Page::Organisations::OrganisationShow.new }
  let(:notifications_index_page) { PageObjects::Page::Notifications::IndexPage.new }

  let(:provider) { build :provider }
  let(:access_request) { build :access_request }
  # TODO: remove admin flag when we are ready to release to users
  let(:user) { build :user, admin: true }

  before do
    stub_omniauth(user: user)
    stub_api_v2_resource(provider)
    stub_api_v2_resource(provider.recruitment_cycle)
    stub_api_v2_resource_collection([access_request])
  end

  context "When the provider is not an accredited body" do
    it "does not have the notifications link" do
      when_i_visit_providers_page
      then_i_should_not_see_notifications_link
    end
  end

  context "When the provider is an accredited body" do
    let(:provider) { build :provider, accredited_body?: true }

    it "organisation page does have the notifications link" do
      when_i_visit_accredited_body_page
      then_i_should_see_notifications_link
    end

    describe "User opting into notifications" do
      it "allows the user to opt into notifications" do
        given_a_user_does_not_have_saved_notifications
        when_i_visit_accredited_body_page
        and_i_click_on_notifications_link
        then_the_notifications_page_is_displayed
        and_no_radio_buttons_are_selected
        and_i_opt_into_notifications # add stub here
        and_save_my_choice
        then_i_should_see_my_preferences_have_been_saved
        and_i_click_on_notifications_link
        then_yes_radio_button_is_preselected
      end
    end

    describe "User opting out of notifications" do
      it "allows the user to opt out notifications" do
        given_a_user_has_two_saved_notifications
        when_i_visit_accredited_body_page
        and_i_click_on_notifications_link
        then_the_notifications_page_is_displayed
        # then_yes_radio_button_is_preselected
        and_i_opt_out_of_notifications
        and_save_my_choice
        then_i_should_see_my_preferences_have_been_saved
        # and_i_click_on_notifications_link
        # then_no_radio_button_is_preselected
      end
    end
  end

private

  def given_a_user_has_two_saved_notifications
    notification1 = build(:notification, user_id: user.id)
    notification2 = build(:notification, user_id: user.id)

    stub_api_v2_resource_collection([notification1, notification2])
  end

  def given_a_user_does_not_have_saved_notifications
    stub_api_v2_request(
      "/users/#{user.id}/notifications",
      resource_list_to_jsonapi([]),
    )
  end

  def when_i_visit_providers_page
    visit provider_path(provider.provider_code)
  end

  def when_i_visit_accredited_body_page
    when_i_visit_providers_page
  end

  def then_i_should_see_notifications_link
    expect(organisation_show_page).to have_notifications_preference_link
  end

  def then_i_should_not_see_notifications_link
    expect(organisation_show_page).not_to have_notifications_preference_link
  end

  def and_i_click_on_notifications_link
    organisation_show_page.notifications_preference_link.click
  end

  def then_the_notifications_page_is_displayed
    expect(notifications_index_page).to be_displayed
  end

  def and_no_radio_buttons_are_selected
    expect(notifications_index_page.opt_in_radio).not_to be_checked
    expect(notifications_index_page.opt_out_radio).not_to be_checked
  end

  def and_i_opt_into_notifications
    notifications_index_page.opt_in_radio.click

  end

  def and_i_opt_out_of_notifications
    notifications_index_page.opt_out_radio.click
  end

  def and_save_my_choice
    notifications_index_page.save_button.click
  end

  def then_i_should_see_my_preferences_have_been_saved
    expect(organisation_show_page)
      .to have_content("Your notification preferences have been saved")
  end

  def then_yes_radio_button_is_preselected
    expect(notifications_index_page.opt_in_radio).to be_checked
  end

  def then_no_radio_button_is_preselected
    expect(notifications_index_page.opt_in_radio).to be_checked
  end
end
