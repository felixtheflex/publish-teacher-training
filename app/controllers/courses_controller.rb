class CoursesController < ApplicationController
  decorates_assigned :course
  before_action :initialise_errors
  before_action :build_recruitment_cycle
  before_action :build_courses, only: %i[index about requirements fees salary]
  before_action :build_course, except: %i[index preview]
  before_action :build_course_for_preview, only: :preview
  before_action :build_provider, except: %i[index confirmation]
  before_action :filter_courses, only: %i[about requirements fees salary]
  before_action :build_copy_course, if: -> { params[:copy_from].present? }

  def index; end

  def details; end

  def request_change; end

  def confirmation
    @provider = Provider
      .where(recruitment_cycle_year: @recruitment_cycle.year)
      .find(params[:provider_code])
      .first
  end

  def new
    redirect_to new_provider_recruitment_cycle_courses_outcome_path(@course.provider_code, @course.recruitment_cycle_year)
  end

  def update
    # Course length should be saved as `course_length` so if "other" is selected then pass that text value into `course_length`
    if params[:course][:course_length_other_length].present? && params[:course][:course_length] == 'Other'
      params[:course][:course_length] = params[:course][:course_length_other_length]
    end
    params[:course].delete(:course_length_other_length)

    if @course.update(course_params)
      flash[:success] = 'Your changes have been saved'
      redirect_to(
        provider_recruitment_cycle_course_path(
          @course.provider_code,
          @course.recruitment_cycle_year,
          @course.course_code
        )
      )
    else
      @errors = @course.errors.messages

      render course_params["page"].to_sym
    end
  end

  def show
    @published = flash[:success]
    flash.delete(:success)

    @errors = flash[:error_summary]
    flash.delete(:error_summary)
  end

  def about
    show_deep_linked_errors(%i[about_course interview_process how_school_placements_work])

    if params[:copy_from].present?
      @copied_fields = [
        ['About the course', 'about_course'],
        ['Interview process', 'interview_process'],
        ['How school placements work', 'how_school_placements_work']
      ].keep_if { |_name, field| copy_field_if_present_in_source_course(field) }
    end
  end

  def requirements
    show_deep_linked_errors(%i[required_qualifications personal_qualities other_requirements])

    if params[:copy_from].present?
      @copied_fields = [
        ['Qualifications needed', 'required_qualifications'],
        ['Personal qualities', 'personal_qualities'],
        ['Other requirements', 'other_requirements']
      ].keep_if { |_name, field| copy_field_if_present_in_source_course(field) }
    end
  end

  def fees
    show_deep_linked_errors(%i[course_length fee_uk_eu fee_international fee_details financial_support])

    if params[:copy_from].present?
      @copied_fields = [
        ['Course length', 'course_length'],
        ['Fee for UK and EU students', 'fee_uk_eu'],
        ['Fee for international students', 'fee_international'],
        ['Fee details', 'fee_details'],
        ['Financial support', 'financial_support']
      ].keep_if { |_name, field| copy_field_if_present_in_source_course(field) }
    end
  end

  def salary
    show_deep_linked_errors(%i[course_length salary_details])

    if params[:copy_from].present?
      @copied_fields = [
        ['Course length', 'course_length'],
        ['Salary details', 'salary_details']
      ].keep_if { |_name, field| copy_field_if_present_in_source_course(field) }
    end
  end

  def withdraw; end

  def delete; end

  def preview; end

  def destroy
    if params[:course][:confirm_course_code] == @course.course_code
      @course.destroy
      redirect_to provider_recruitment_cycle_courses_path(@provider.provider_code, @provider.recruitment_cycle_year)
      flash[:success] = "#{@course.name} (#{@course.course_code}) has been deleted"
    else
      flash[:error] = "Enter the course code (#{@course.course_code}) to delete this course"
      redirect_to delete_provider_recruitment_cycle_course_path(@provider.provider_code, @course.recruitment_cycle_year, @course.course_code)
    end
  end

  def publish
    if @course.publish
      flash[:success] = "Your course has been published."
    else
      flash[:error_summary] = @course.errors.messages
    end

    redirect_to provider_recruitment_cycle_course_path(@provider.provider_code, @course.recruitment_cycle_year, @course.course_code)
  end

private

  def course_params
    params.require(:course).permit(
      :page,
      :about_course,
      :course_length,
      :course_length_other_length,
      :fee_details,
      :fee_international,
      :fee_uk_eu,
      :financial_support,
      :how_school_placements_work,
      :interview_process,
      :other_requirements,
      :personal_qualities,
      :salary_details,
      :required_qualifications,
      :qualification, # qualification is actually "outcome"
      :maths,
      :english,
      :science
    )
  end

  def build_course_for_preview
    cycle_year = params.fetch(
      :recruitment_cycle_year,
      Settings.current_cycle
    )

    @provider_code = params[:provider_code]
    @course = Course
      .includes(site_statuses: [:site])
      .includes(provider: [:sites])
      .includes(:accrediting_provider)
      .where(recruitment_cycle_year: cycle_year)
      .where(provider_code: @provider_code)
      .find(params[:code])
      .first
  rescue JsonApiClient::Errors::NotFound
    render file: 'errors/not_found', status: :not_found
  end

  def build_course
    cycle_year = params.fetch(
      :recruitment_cycle_year,
      Settings.current_cycle
    )

    @provider_code = params[:provider_code]
    @course = Course
      .includes(:sites)
      .includes(provider: [:sites])
      .includes(:accrediting_provider)
      .where(recruitment_cycle_year: cycle_year)
      .where(provider_code: @provider_code)
      .find(params[:code])
      .first
  rescue JsonApiClient::Errors::NotFound
    render file: 'errors/not_found', status: :not_found
  end

  def build_provider
    @provider = @course.provider
  end

  def build_courses
    cycle_year = params.fetch(
      :recruitment_cycle_year,
      Settings.current_cycle
    )

    @provider = Provider
      .includes(courses: [:accrediting_provider])
      .where(recruitment_cycle_year: cycle_year)
      .find(params[:provider_code])
      .first

    # rubocop:disable Style/MultilineBlockChain
    @courses_by_accrediting_provider = @provider
      .courses
      .group_by { |course|
        # HOTFIX: A courses API response no included hash seems to cause issues with the
        # .accrediting_provider relationship lookup. To be investigated, for now,
        # if this throws, it's self-accredited.
        begin
          course.accrediting_provider&.provider_name || @provider.provider_name
        rescue StandardError
          @provider.provider_name
        end
      }
      .sort_by { |accrediting_provider, _| accrediting_provider.downcase }
      .map { |provider_name, courses|
      [provider_name, courses.sort_by { |course| [course.name, course.course_code] }
                             .map(&:decorate)]
    }
      .to_h
    # rubocop:enable Style/MultilineBlockChain

    @self_accredited_courses = @courses_by_accrediting_provider.delete(@provider.provider_name)
  end

  def filter_courses
    @courses_by_accrediting_provider = @courses_by_accrediting_provider.reject { |c| c == course.id }
    @self_accredited_courses = @self_accredited_courses&.reject { |c| c.id == course.id }
  end

  def build_copy_course
    cycle_year = params.fetch(
      :recruitment_cycle_year,
      Settings.current_cycle
    )

    @source_course = Course.includes(:sites)
                           .includes(provider: [:sites])
                           .includes(:accrediting_provider)
                           .where(recruitment_cycle_year: cycle_year)
                           .where(provider_code: @provider_code)
                           .find(params[:copy_from])
                           .first
  end

  def copy_field_if_present_in_source_course(field)
    source_value = @source_course[field]
    course[field] = source_value if source_value.present?
  end

  def initialise_errors
    @errors = {}
  end

  def show_deep_linked_errors(attributes)
    return if params[:display_errors].blank?

    @course.publishable?
    @errors = @course.errors.messages.select { |key| attributes.include? key }
  end

  def build_recruitment_cycle
    cycle_year = params.fetch(
      :recruitment_cycle_year,
      Settings.current_cycle
    )

    @recruitment_cycle = RecruitmentCycle.find(cycle_year).first
  end
end
