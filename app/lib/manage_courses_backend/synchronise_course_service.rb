module ManageCoursesBackend
  class SynchroniseCourseService
    prepend SimpleCommand
    include Connection

    attr_reader :provider_code, :course_code, :token

    def initialize(provider_code:, course_code:, token:)
      @provider_code = provider_code
      @course_code   = course_code
      @token         = token
    end

    def call
      return if result_true?

      errors.add(
        :failed_to_synchronise,
        'Failed to synchronise course with manage-courses-backend'
      )
    end

  private

    def path
      path_template.expand(
        provider_code: provider_code,
        course_code:   course_code
      ).to_s
    end

    def path_template
      Addressable::Template.new(
        "providers/{provider_code}/courses/{course_code}/" \
          "sync_with_search_and_compare"
      )
    end

    def result_true?
      JSON.parse(response_body).dig('result') == true
    end

    def response_body
      connection(token).post(path)&.body || '{}'
    end
  end
end
