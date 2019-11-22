module AccreditedBody
  class CoursesController < ApplicationController
    # decorates_assigned :provider
    before_action :build_recruitment_cycle
    # rescue_from JsonApiClient::Errors::NotFound, with: :not_found
    before_action :build_provider
    #
    def index
      # https://stackoverflow.com/questions/94502/in-rails-how-to-return-records-as-a-csv-file/222698#222698
      # headers["Content-type"] = "text/csv"
      courses = @provider.current_accredited_courses.map do |c|
              {
                  provider_code: c.provider.provider_code,
                  provider_name: c.provider.provider_name,
                  course_code: c.course_code,
                  course_name: c.name,
                  study_mode: c.study_mode,
                  program_type: c.program_type,
                  qualification: c.qualification,
                  content_status: c.content_status,
                  sites: c.site_statuses.map do |ss|
                    {
                        site_code: ss.site.code,
                      site_name: ss.site.location_name,
                      site_status: ss.status,
                      site_published: ss.published_on_ucas?,
                      site_vacancies: ss.vac_status,
                    }
                end,
              }
          end
          out = courses.select { |c| c[:sites].any? } # they aren't on "Find" or "Apply" if they have no sites
          out = flatten_sites(out)
          out = out.sort_by do |x|
              [
                  x[:provider_name],
                  x[:course_name],
                  x[:program_type],
                  x[:qualification],
                  x[:site_name],
                ]
          end
      @courses = out

      respond_to do |format|
        format.csv
      end
    end

    def build_recruitment_cycle
      cycle_year = params.fetch(
        :recruitment_cycle_year,
        Settings.current_cycle,
        )

      @recruitment_cycle = RecruitmentCycle.find(cycle_year).first
    end

    def build_provider
      @provider = Provider
                    .includes(current_accredited_courses: [:provider, site_statuses: [:site]])
                    .where(recruitment_cycle_year: @recruitment_cycle.year)
                    .find(params[:provider_code])
                    .first
    end

    def flatten_sites(courses)
      out = []
      courses.each do |c|
          c[:sites].each do |s|
              out << c.except(:sites).merge(s)
            end
        end
      out
    end
  end
end
