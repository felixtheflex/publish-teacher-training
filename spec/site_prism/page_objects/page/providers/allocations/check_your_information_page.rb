module PageObjects
  module Page
    module Providers
      module Allocations
        class CheckYourInformationPage < PageObjects::Base
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/allocations/request"

          element :header, "h1"
          element :number_of_places, "dd.govuk-summary-list__value"
          element :change_link, "dd.govuk-summary-list__actions a"
          element :send_request_button, "input[value='Send request']"
        end
      end
    end
  end
end
