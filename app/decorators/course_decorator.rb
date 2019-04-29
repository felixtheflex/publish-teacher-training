class CourseDecorator < ApplicationDecorator
  delegate_all

  def name_and_code
    "#{object.name} (#{object.course_code})"
  end

  def vacancies(provider = object.provider)
    content = object.has_vacancies? ? 'Yes' : 'No'
    content += " (" + edit_vacancy_link + ")" if provider.opted_in?
    content.html_safe
  end

  def on_find(provider_code = object.provider.provider_code)
    if object.findable?
      h.govuk_link_to("Yes - view online", h.search_ui_course_page_url(provider_code: provider_code, course_code: object.course_code))
    else
      not_on_find
    end
  end

  def open_or_closed_for_applications
    object.open_for_applications? ? 'Open' : 'Closed'
  end

  def outcome
    object.qualifications.sort.map(&:upcase).join(' with ')
  end

  def is_send?
    object.is_send? ? 'Yes' : 'No'
  end

  def funding
    case object.funding
    when 'salary'
      'Salaried'
    when 'apprenticeship'
      'Teaching apprenticeship (with salary)'
    when 'fee'
      'Fee paying (no salary)'
    end
  end

  def apprenticeship?
    object.funding == 'apprenticeship' ? 'Yes' : 'No'
  end

  def sorted_subjects
    object.subjects.sort.join("<br>").html_safe
  end

  def content_status_badge
    return if object.not_running?

    badge = h.content_tag(:div, content_tag_content, class: "govuk-tag phase-tag--small #{content_tag_css_class}")
    badge += h.content_tag_unpublished if object.has_unpublished_changes?
    badge.html_safe
  end

  def length
    case object.course_length
    when 'OneYear'
      '1 year'
    when 'TwoYears'
      'Up to 2 years'
    else
      object.course_length
    end
  end

  def ucas_status
    case object.ucas_status
    when 'running'
      'Running'
    when 'new'
      'New – not yet running'
    when 'not_running'
      'Not running'
    end
  end

private

  def content_tag_content
    case object.content_status
    when 'published'
      'Published'
    when 'empty'
      'Empty'
    when 'draft'
      'Draft'
    when 'published_with_unpublished_changes'
      'Published&nbsp;*'
    end
  end

  def content_tag_css_class
    case course.content_status
    when 'published'
      'phase-tag--published'
    when 'empty'
      'phase-tag--no-content'
    when 'draft'
      'phase-tag--draft'
    when 'published_with_unpublished_changes'
      'phase-tag--published'
    end
  end

  def content_tag_unpublished
    h.content_tag(:div, '*&nbsp;Unpublished&nbsp;changes', class: 'govuk-body govuk-body-s govuk-!-margin-bottom-0 govuk-!-margin-top-1')
  end

  def not_on_find
    if object.new_and_not_running?
      'No – ' + (object.provider.opted_in? ? 'still in draft' : 'must be published on UCAS').to_s
    else
      'No'
    end
  end

  def edit_vacancy_link
    h.link_to('Edit', h.vacancies_provider_course_path(code: object.course_code), class: 'govuk-link')
  end
end