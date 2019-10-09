class ApplicationDecorator < Draper::Decorator
  def status_tag
    tag = h.content_tag(:div, status_tag_content.html_safe, class: "govuk-tag phase-tag--small #{status_tag_css_class}")
    tag += unpublished_status_hint if object.has_unpublished_changes?
    tag.html_safe
  end

private

  def status_tag_content
    return status_tags[:withdrawn][:content] if object.ucas_status == "not_running"

    status_tags[object.content_status.to_sym][:content]
  end

  def status_tag_css_class
    return status_tags[:withdrawn][:css_class] if object.ucas_status == "not_running"

    status_tags[object.content_status.to_sym][:css_class]
  end

  def status_tags
    {
      published: { css_class: "phase-tag--published", content: "Published" },
      withdrawn: { css_class: "phase-tag--withdrawn", content: "Withdrawn" },
      empty: { css_class: "phase-tag--no-content", content: "Empty" },
      draft: { css_class: "phase-tag--draft", content: "Draft" },
      published_with_unpublished_changes: { css_class: "phase-tag--published",  content: "Published&nbsp;*" },
      rolled_over: { css_class: "phase-tag--no-content", content: "Rolled over" },
    }
  end

  def unpublished_status_hint
    h.content_tag(:div, "*&nbsp;Unpublished&nbsp;changes".html_safe, class: "govuk-body govuk-body-s govuk-!-margin-bottom-0 govuk-!-margin-top-1")
  end
end
