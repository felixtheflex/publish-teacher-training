module PageObjects
  module Page
    module Providers
      module Allocations
        class NewPage < PageObjects::Base
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/allocations/new"

          element :number_of_places_yes_input, '[data-qa="number_of_places_yes"]'
          element :number_of_places_no_input, '[data-qa="number_of_places_no"]'
          element :continue_button, '[data-qa="continue_button"]'
        end
      end
    end
  end
end
