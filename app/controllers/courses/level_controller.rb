module Courses
  class LevelController < ApplicationController
    include CourseBasicDetailConcern

    def continue
      @errors = errors

      if @errors.present?
        render :new
      else
        redirect_to new_provider_recruitment_cycle_courses_entry_requirements_path(
          params[:provider_code],
          params[:recruitment_cycle_year],
          course_params
        )
      end
    end

  private

    def errors; end

    def course_params
      params.require(:course).permit(:level, :is_send)
    end
  end
end