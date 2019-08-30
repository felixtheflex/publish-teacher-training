require "rails_helper"

feature 'new course outcome', type: :feature do
  let(:new_outcome_page) do
    PageObjects::Page::Organisations::Courses::NewOutcomePage.new
  end
  let(:provider) { build(:provider) }
  let(:course) { build(:course, provider: provider) }
  let(:build_new_course_request) { stub_build_course_request(initial_params) }
  let(:build_new_course_with_outcome_request) do
    stub_build_course_request(initial_params.merge('attrs[course][qualification]' => 'qts'))
  end

  before do
    stub_omniauth
    stub_api_v2_resource(provider)
    new_course = build(:course, :new, provider: provider, gcse_subjects_required_using_level: true)
    stub_api_v2_new_resource(new_course)
    build_new_course_request
    build_new_course_with_outcome_request
  end

  context "Visiting the page" do
    scenario "builds the new course on the API" do
      visit_new_outcomes_page

      expect(build_new_course_request).to have_been_made
    end
  end

  context "Selecting QTS as the qualification" do
    before do
      visit_new_outcomes_page

      choose('course_qualification_qts')
      click_on 'Continue'
    end

    scenario "sends user to entry requirements" do
      expect(current_path).to eq new_provider_recruitment_cycle_courses_entry_requirements_path(provider.provider_code, provider.recruitment_cycle_year)
    end

    scenario "builds the updated new course on the API" do
      # this is currently made twice, once by this and once by the entry requirements page loading
      expect(build_new_course_with_outcome_request).to have_been_made.times(2)
    end
  end

private

  def visit_new_outcomes_page
    visit "/organisations/#{provider.provider_code}/#{provider.recruitment_cycle.year}" \
    "/courses/outcome/new"
  end

  def stub_build_course_request(params)
    stub_api_v2_request(
      build_course_request_url(params),
      course.to_jsonapi
    )
  end

  def build_course_request_url(params)
    base_url = "/recruitment_cycles/#{provider.recruitment_cycle_year}" \
      "/providers/#{provider.provider_code}/courses/build_new?"
    url_params = params.map { |k, v| "#{k}=#{v}" }.join("&")

    base_url + url_params
  end

  def initial_params
    {
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year
    }
  end
end
