module Courses
  class OutcomeController < ApplicationController
    include CourseBasicDetailConcern

    def continue
      @errors = errors

      if @errors.present?
        render :new
      else
        redirect_to new_provider_recruitment_cycle_courses_entry_requirements_path(
                      # TODO: don't pass along everything in params, e.g.
                      #       :controller, :action, etc. only :course probably
                      params.to_unsafe_hash
        )
      end
    end

  private

    def errors
      params.dig(:course, :qualification) ? {} : { qualification: ["Pick an outcome"] }
    end

    # def course_params
    #   params.require(:course).permit(:qualification)
    # end
  end
end
