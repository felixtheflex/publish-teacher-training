module EditBasicDetailConcern
  extend ActiveSupport::Concern

  included do
    decorates_assigned :course
    before_action :build_course
  end

  def new
    render :edit
  end

  def edit; end

  def update
    @errors = errors
    return render :edit if @errors.any?

    if @course.update(course_params)
      flash[:success] = 'Your changes have been saved'
      redirect_to(
        details_provider_recruitment_cycle_course_path(
          @course.provider_code,
          @course.recruitment_cycle_year,
          @course.course_code
        )
      )
    else
      @errors = @course.errors.messages
      render :edit
    end
  end

  def next_step
    @errors = errors
    return render :edit if @errors.any?

    current_step = controller_name.gsub('courses/', '')
    next_action_index = CoursesController::CREATE_STEPS.index(current_step) + 1
    next_action = CoursesController::CREATE_STEPS[next_action_index]
    redirect_to(action: :new,
                controller: "courses/#{next_action}",
                params: { course: create_params })
  end

private

  def build_course
    @course = Course
      .where(recruitment_cycle_year: params[:recruitment_cycle_year])
      .where(provider_code: params[:provider_code])
      .find(params[:code])
      .first
  end

  def create_params
    params.require('course')
      .permit(:qualification)
  end
end
