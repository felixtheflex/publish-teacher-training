module Providers
  class EditInitialAllocationsController < ApplicationController
    def do_you_want
      if request.post?
        redirect_to number_of_places_provider_recruitment_cycle_allocation_path(
          provider_code: allocation.accredited_body.provider_code,
          recruitment_cycle_year: recruitment_cycle.year,
          training_provider_code: allocation.provider.provider_code,
          id: allocation.id,
        )
      else
      render locals: {
        training_provider: training_provider,
        allocation: allocation,
        provider: provider,
      }
      end
    end

    def number_of_places
      if request.post?
        redirect_to check_answers_provider_recruitment_cycle_allocation_path(
          provider_code: allocation.accredited_body.provider_code,
          recruitment_cycle_year: recruitment_cycle.year,
          training_provider_code: allocation.provider.provider_code,
          number_of_places: params[:allocation][:number_of_places],
          id: allocation.id,
        )
      else
      render locals: {
        training_provider: training_provider,
        allocation: allocation,
        recruitment_cycle: recruitment_cycle,
      }
      end
    end

    def check_answers
      if request.post?
        update
        redirect_to provider_recruitment_cycle_allocation_path(
          provider_code: allocation.accredited_body.provider_code,
          recruitment_cycle_year: recruitment_cycle.year,
          training_provider_code: allocation.provider.provider_code,
          id: allocation.id,
        )
      else
      render locals: {
        training_provider: training_provider,
        allocation: allocation,
        recruitment_cycle: recruitment_cycle,
        number_of_places: params[:number_of_places]
      }
      end
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

    def update
      allocation.number_of_places = params[:allocation][:number_of_places].to_i
      allocation.set_all_dirty!
      allocation.save

      @allocation = Allocation.includes(:provider, :accredited_body)
                                .find(params[:id])
                                .first
    end
  end
end
