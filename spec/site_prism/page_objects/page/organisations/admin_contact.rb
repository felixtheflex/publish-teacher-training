module PageObjects
  module Page
    module Organisations
      class AdminContact < PageObjects::Base
        set_url "/organisations/{provider_code}/ucas-contacts/admin-contact"

        element :main_heading, '[data-qa="ucas_contacts__admin_contact__main_heading"]'

        section :alerts_enabled_fields, '[data-qa="ucas_contacts__alerts_enabled"]' do
          element :all, '[data-qa="ucas_contacts__alerts_enabled__all"]'
          element :none, '[data-qa="ucas_contacts__alerts_enabled__none"]'
        end
      end
    end
  end
end
