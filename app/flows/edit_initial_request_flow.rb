class EditInitialRequestFlow
  include Rails.application.routes.url_helpers

  PE_SUBJECT_CODE = "C6".freeze

  attr_reader :params

  def initialize(params:)
    @params = params
  end

  def template
    if edit_request_type_page?
      "providers/allocations/edit_request_type"
    elsif number_of_places_page?
      "providers/allocations/edit_number_of_places"
    elsif check_edited_information_page?
      "providers/allocations/check_edited_information"
    else
      "providers/allocations/edit_request_type"
    end
  end

  def locals
    if edit_number_of_places_page? || check_edited_information_page?
      {
        training_provider: allocation.provider,
        allocation: allocation,
      }
    elsif edit_request_type_page?
      {
        allocation: allocation,
        form_object: form_object,
      }
    else
      {
        allocation: allocation,
        form_object: form_object,
        training_provider: allocation.provider,
      }
    end
  end

  def redirect?
    
  end

  def redirect_path

  end

  delegate :valid?, to: :form_object

private

  def allocation
    @allocation ||= Allocation.includes(:provider, :accredited_body)
                              .find(params[:id])
                              .first
  end

  def request_type_declined?
    params[:request_type] == AllocationsView::RequestType::DECLINED
  end

  def form_object
    permitted_params = params.slice(:id)
                             .permit(:id)

    @form_object ||= EditInitialRequestForm.new(permitted_params)
  end

  def provider
    @provider ||= Provider
      .where(recruitment_cycle_year: recruitment_cycle.year)
      .find(params[:provider_code])
      .first
  end

  def pick_a_provider_page?
    training_provider_search? && training_providers_from_query_without_associated.count > 1
  end

  def number_of_places_page?
    training_provider_selected? ||
      (params[:training_provider_query].present? && one_search_result?) || params[:change]
  end

  def check_your_information_page?
    training_provider_selected? && params[:number_of_places].present? && !params[:change]
  end

end
