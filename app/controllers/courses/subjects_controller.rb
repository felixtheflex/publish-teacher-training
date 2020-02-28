module Courses
  class SubjectsController < ApplicationController
    decorates_assigned :course
    before_action :build_course, only: %i[edit update]
    before_action :build_course_params, only: [:continue]
    include CourseBasicDetailConcern

    def edit; end

    def continue
      super
    end

    def update
      if subjects_have_not_been_changed?
        flash[:success] = "Your subject hasn't been changed"
        redirect_to(
          details_provider_recruitment_cycle_course_path(
            @course.provider_code,
            @course.recruitment_cycle_year,
            @course.course_code,
          ),
        )
      elsif @course.update(subjects: selected_subjects)
        flash[:success] = "Your changes have been saved"
        redirect_to(
          modern_languages_provider_recruitment_cycle_course_path(
            @course.provider_code,
            @course.recruitment_cycle_year,
            @course.course_code,
          ),
        )
      else
        @errors = @course.errors.messages
        render :edit
      end
    end

  private

    def subjects_have_not_been_changed?
      subjects_match?(selected_subjects, existing_non_language_subjects)
    end

    def subjects_match?(subject_array_a, subject_array_b)
      return false if subject_array_a.length != subject_array_b.length

      subject_array_a.zip(subject_array_b).all? do |subject_a, subject_b|
        subject_a.present? && subject_b.present? && subject_a.id == subject_b.id
      end
    end

    def existing_non_language_subjects
      @course.subjects.select do |course_subject|
        is_a_non_language_subject?(course_subject)
      end
    end

    def selected_subjects
      selected_subject_ids = params
        .dig(:course)
        .slice(:master_subject_id, :subordinate_subject_id)
        .to_unsafe_h
        .values
        .select(&:present?)

      selected_subject_ids.map do |subject_id|
        subject_hash = find_subject(subject_id)
        Subject.new(subject_hash.to_h)
      end
    end

    def find_subject(subject_id)
      @course.meta[:edit_options][:subjects].find do |subject|
        subject[:id] == subject_id
      end
    end

    def is_a_non_language_subject?(subject_to_find)
      @course.meta[:edit_options][:subjects].any? do |subject|
        subject[:id] == subject_to_find.id
      end
    end

    def current_step
      :subjects
    end

    def error_keys
      [:subjects]
    end

    def build_course
      @course = Course
                  .includes(:subjects, :site_statuses)
                  .where(recruitment_cycle_year: params[:recruitment_cycle_year])
                  .where(provider_code: params[:provider_code])
                  .find(params[:code])
                  .first
    end

    def build_course_params
      selected_master = params[:course][:master_subject_id]
      selected_subordinate = nil
      selected_subordinate = params[:course][:subordinate_subject_id] if params[:course][:subordinate_subject_id].present?
      previous_subject_selections = params[:course][:subjects_ids]

      params[:course][:subjects_ids] = []
      params[:course][:subjects_ids] << selected_master
      params[:course][:subjects_ids] << selected_subordinate if selected_subordinate
      params[:course].delete(:master_subject_id)
      params[:course].delete(:subordinate_subject_id)

      build_new_course

      if modern_language_selected?
        params[:course][:subjects_ids]
            .concat(strip_non_language_subject_ids(previous_subject_selections))
      end
    end

    def modern_language_selected?
      @course.meta[:edit_options][:modern_languages].present?
    end

    def strip_non_language_subject_ids(subject_ids)
      return [] unless subject_ids
      subject_ids.filter { |id| available_languages_ids.include?(id) }
    end

    def available_languages_ids
      @course.meta[:edit_options][:modern_languages].map do |language|
        language["id"]
      end
    end
  end
end
