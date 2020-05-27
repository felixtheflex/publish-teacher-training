class EditInitialRequestFlow
  include Rails.application.routes.url_helpers

  attr_reader :params

  def initialize(params:)
    @params = params
  end

  def template
    if params[:allocation] && params[:allocation][:request_type] == "initial"
      "providers/allocations/edit_number_of_places"
    elsif params[:allocation] && params[:allocation][:number_of_places].present?
      "providers/allocations/check_edited_information"
    else
      "providers/allocations/edit_initial_request"
    end
  end

  def locals
    {
      allocation: allocation,
      training_provider: allocation.provider,
      recruitment_cycle: recruitment_cycle,
    }
  end

  def redirect?
    false
  end

  def redirect_path
    "https://example.com"
  end

  def update
    # TODO change to DELETE
    allocation.request_type = params[:allocation][:request_type]
    allocation.save if allocation.changed?

    # must reload otherwise associations are nil
    @allocation = Allocation.includes(:provider, :accredited_body)
                            .find(params[:id])
                            .first
  end

private

  def allocation
    @allocation ||= Allocation.includes(:provider, :accredited_body)
                              .find(params[:id])
                              .first
  end

  def recruitment_cycle
    return @recruitment_cycle if @recruitment_cycle

    cycle_year = params.fetch(:year, Settings.current_cycle)

    @recruitment_cycle = RecruitmentCycle.find(cycle_year).first
  end
end
