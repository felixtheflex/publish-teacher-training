class EditRepeatRequestFlow
  include Rails.application.routes.url_helpers

  attr_reader :params

  def initialize(params:)
    @params = params
  end

  def template
    "providers/allocations/edit_repeat_request"
  end

  def locals
    {
      allocation: allocation,
      training_provider: allocation.provider,
    }
  end

  def redirect?
    true
  end

  def redirect_path
    provider_recruitment_cycle_allocation_path(allocation.accredited_body.provider_code,
                                               recruitment_cycle.year,
                                               allocation.provider.provider_code,
                                               id: allocation.id)
  end

  def update
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
