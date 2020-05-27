module Providers
  class AllocationsController < ApplicationController
    before_action :build_recruitment_cycle
    before_action :build_provider
    before_action :build_training_provider, except: %i[index initial_request]
    before_action :require_provider_to_be_accredited_body!
    before_action :require_admin_permissions!

    PE_SUBJECT_CODE = "C6".freeze

    def index
      @training_providers = @provider.training_providers(
        recruitment_cycle_year: @recruitment_cycle.year,
        "filter[subjects]": PE_SUBJECT_CODE,
        "filter[funding_type]": "fee",
      )

      allocations = Allocation
                      .includes(:provider, :accredited_body)
                      .where(provider_code: params[:provider_code])
                      .all

      @allocations_view = AllocationsView.new(
        allocations: allocations, training_providers: @training_providers,
      )
    end

    def new_repeat_request; end

    def edit
      @allocation = Allocation.find(params[:id]).first
    end

    def create
      # TODO: we need to add error handling here

      allocation = AllocationServices::Create.call(
        accredited_body_code: @provider.provider_code,
        provider_id: @training_provider.id,
        request_type: params[:allocation][:request_type],
        number_of_places: params[:number_of_places],
      )

      redirect_to provider_recruitment_cycle_allocation_path(id: allocation.id)
    end

    def update
      @allocation = Allocation.find(params[:id]).first

      @allocation.request_type = params[:allocation][:request_type]

      @allocation.save if @allocation.changed?

      redirect_to provider_recruitment_cycle_allocation_path(id: @allocation.id)
    end

    def show
      @allocation = Allocation.find(params[:id]).first
    end

    def edit_initial_request
      flow = EditInitialReuqestFlow.new(params: params)

      if reuqest.post? && flow.valid? && flow.redirect?
        redirect_to flow.redirect_path
      else
        render flow.template, locals: flow.locals
      end
    end

    def initial_request
      flow = InitialRequestFlow.new(params: params)

      if request.post? && flow.valid? && flow.redirect?
        redirect_to flow.redirect_path
      else
        render flow.template, locals: flow.locals
      end
    end

  private

    def build_training_provider
      @training_provider = Provider
       .where(recruitment_cycle_year: @recruitment_cycle.year)
       .find(params[:training_provider_code])
       .first
    end

    def build_provider
      @provider = Provider
        .where(recruitment_cycle_year: @recruitment_cycle.year)
        .find(params[:provider_code])
        .first
    end

    def build_recruitment_cycle
      cycle_year = params.fetch(:year, Settings.current_cycle)

      @recruitment_cycle = RecruitmentCycle.find(cycle_year).first
    end

    def require_provider_to_be_accredited_body!
      render "errors/not_found", status: :not_found unless @provider.accredited_body?
    end

    def require_admin_permissions!
      render "errors/forbidden", status: :forbidden unless user_is_admin?
    end
  end
end
