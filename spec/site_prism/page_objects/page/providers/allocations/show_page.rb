module PageObjects
  module Page
    module Providers
      module Allocations
        class ShowPage < PageObjects::Base
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/allocations/show"

          element :confirmation_panel, "[data-qa=confirmation_panel]"
        end
      end
    end
  end
end
