module PageObjects
  module Page
    module Organisations
      class OrganisationPage < PageObjects::Base
        set_url "/organisations/{provider_code}"

        element :locations, "[data-qa=provider__locations]", text: "Locations"
        element :courses, "[data-qa=provider__courses]", text: "Courses"
        element :current_cycle, "[data-qa=provider__courses__current_cycle]", text: "Current cycle"
        element :next_cycle, "[data-qa=provider__courses__next_cycle]", text: "Next cycle"

        section :pagination, ".pub-c-pagination" do
          element :next_page, ".pub-c-pagination__link-title"
        end
      end
    end
  end
end
