class EditRequestFlow
  include Rails.application.routes.url_helpers

  PE_SUBJECT_CODE = "C6".freeze

  attr_reader :params

  def initialize(params:)
    @params = params
  end

  def template
    if allocation.request_type == "initial"
      "providers/allocations/edit_initial_request"
    else
      "providers/allocations/edit_repeat_request"
    end
  end

  def locals
    {
      allocation: allocation,
      training_provider: allocation.provider
    }
  end

  def redirect?
    true
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

  def form_object
    permitted_params = params.slice(:id)
                             .permit(:id)

    @form_object ||= EditInitialRequestForm.new(permitted_params)
  end
end
