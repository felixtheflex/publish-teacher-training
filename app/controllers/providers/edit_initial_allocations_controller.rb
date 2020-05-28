module Providers
  class EditInitialAllocationsController < ApplicationController
    def do_you_want
      render locals: {
        training_provider: training_provider,
        allocation: allocation,
        provider: provider,
      }
    end

    def number_of_places
    end

    def check_answers
    end

    def confirmation
      # @allocation = Allocation.new(request_type: 'initial', provider: { provider_name: 'school A' })
      # or redirect
    end

  private

    def training_provider
      @training_provider ||= Provider
       .where(recruitment_cycle_year: recruitment_cycle.year)
       .find(params[:training_provider_code])
       .first
    end

    def provider
      @provider ||= Provider
        .where(recruitment_cycle_year: recruitment_cycle.year)
        .find(params[:provider_code])
        .first
    end

    def recruitment_cycle
      return @recruitment_cycle if @recruitment_cycle

      cycle_year = params.fetch(:year, Settings.current_cycle)

      @recruitment_cycle = RecruitmentCycle.find(cycle_year).first
    end

    def allocation
      @allocation ||= Allocation.includes(:provider, :accredited_body)
                                .find(params[:id])
                                .first
    end
  end
end
