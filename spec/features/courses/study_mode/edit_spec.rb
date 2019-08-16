require 'rails_helper'

feature 'Edit course study mode', type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:study_mode_page) { PageObjects::Page::Organisations::CourseStudyMode.new }
  let(:course_details_page) { PageObjects::Page::Organisations::CourseDetails.new }
  let(:course_request_change_page) { PageObjects::Page::Organisations::CourseRequestChange.new }
  let(:provider) { build(:provider) }

  before do
    stub_omniauth
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}",
      current_recruitment_cycle.to_jsonapi
    )
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}?include=courses.accrediting_provider",
      build(:provider).to_jsonapi(include: %i[courses accrediting_provider])
    )

    stub_course_request
    stub_course_details_tab
    study_mode_page.load_with_course(course)
  end

  context 'a full time of part time course' do
    let(:course) do
      build(
        :course,
        study_mode: 'full_time_or_part_time',
        edit_options: {
          study_modes: %w[full_time part_time full_time_or_part_time]
        },
        provider: provider
      )
    end

    scenario 'can cancel changes' do
      click_on 'Cancel changes'
      expect(course_details_page).to be_displayed
    end

    scenario 'can navigate to the edit screen and back again' do
      course_details_page.load_with_course(course)
      click_on 'Change full time of part time'
      expect(study_mode_page).to be_displayed
      click_on 'Back'
      expect(course_details_page).to be_displayed
    end

    scenario 'presents a choice for each study mode' do
      expect(study_mode_page).to have_study_mode_fields
      expect(study_mode_page.study_mode_fields)
        .to have_selector('[for="course_study_mode_full_time"]', text: 'Full time')
      expect(study_mode_page.study_mode_fields)
        .to have_selector('[for="course_study_mode_part_time"]', text: 'Part time')
      expect(study_mode_page.study_mode_fields)
          .to have_selector('[for="course_study_mode_full_time_or_part_time"]', text: 'Full time or part time')
    end

    scenario 'has the correct value selected' do
      expect(study_mode_page.study_mode_fields)
        .to have_field('course_study_mode_full_time_or_part_time', checked: true)
    end

    scenario 'can be updated to a full time course' do
      update_course_stub = stub_api_v2_request(
        "/recruitment_cycles/#{course.recruitment_cycle.year}" \
        "/providers/#{provider.provider_code}" \
        "/courses/#{course.course_code}",
        course.to_jsonapi,
        :patch, 200
      )

      choose('course_study_mode_full_time')
      click_on 'Save'

      expect(course_details_page).to be_displayed
      expect(course_details_page.flash).to have_content('Your changes have been saved')
      expect(update_course_stub).to have_been_requested
    end
  end

  context 'a full time course' do
    let(:course) do
      build(
        :course,
        study_mode: 'full_time',
        edit_options: {
          study_modes: %w[full_time part_time full_time_or_part_time]
        },
        provider: provider
      )
    end

    scenario 'updating to a full time of part time course' do
      update_course_stub = stub_api_v2_request(
        "/recruitment_cycles/#{course.recruitment_cycle.year}" \
        "/providers/#{provider.provider_code}" \
        "/courses/#{course.course_code}",
        course.to_jsonapi,
        :patch, 200
      )

      choose('course_study_mode_full_time_or_part_time')
      click_on 'Save'

      expect(course_request_change_page).to be_displayed
      expect(course_request_change_page.title).to have_content('Request a change to this course')
      expect(update_course_stub).not_to have_been_requested
    end
  end

  def stub_course_request
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}/courses" \
      "/#{course.course_code}",
      course.to_jsonapi
    )
  end

  def stub_course_details_tab
    stub_api_v2_request(
      "/recruitment_cycles/#{course.recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}" \
      "/courses/#{course.course_code}" \
      "?include=sites,provider.sites,accrediting_provider",
      course.to_jsonapi(include: [:sites, :accrediting_provider, :recruitment_cycle, provider: :sites])
    )
  end
end