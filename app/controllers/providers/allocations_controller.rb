module Providers
  class AllocationsController < ApplicationController
    before_action :build_allocations # supply dummy data
    before_action :build_recruitment_cycle
    before_action :build_provider
    before_action :build_training_provider, except: %i[index]
    before_action :require_provider_to_be_accredited_body!
    before_action :require_admin_permissions!

    PE_SUBJECT_CODE = "C6".freeze

    def index
      # @training_providers = @provider.training_providers(
      #   recruitment_cycle_year: @recruitment_cycle.year,
      #   "filter[subjects]": PE_SUBJECT_CODE,
      #   "filter[funding_type]": "fee",
      #   )
      # # temporary placeholders
      # @allocation_statuses = [
      #   { status: "NOT YET REQUESTED", status_colour: "grey" },
      #   { status: "NOT REQUESTED", status_colour: "red" },
      #   { status: "REQUESTED", status_colour: "green" },
      # ]
    end

    def requests; end

    def new; end

    def show; end

  private

    # dummy data
    def build_allocations
      @allocations = []
      @allocations <<  { provider_name: "Enfield County School for Girls", status: "Confirm your choice", status_colour: "grey", action: "Confirm choice", action_path: "/new" }
      @allocations <<  { provider_name: "London Academy", status: "NOT REQUESTED", status_colour: "red", action: "Change", action_path: "#" }
      @allocations <<  { provider_name: "University of East Anglia", status: "REQUESTED", status_colour: "green", action: "Change", action_path: "#" }
    end

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
