module PageObjects
  module Page
    module Organisations
      class AdminContact < PageObjects::Base
        set_url "/organisations/{provider_code}/ucas-contacts/admin-contact"

        element :main_heading, '[data-qa="ucas_contacts__admin_contact__main_heading"]'

        section :admin_contact_details_form, '[data-qa="ucas_contacts__admin_details_form"]' do
          element :name, '[data-qa="ucas_contacts__admin_details_form__name"]'
          element :email, '[data-qa="ucas_contacts__admin_details_form__email"]'
          element :telephone, '[data-qa="ucas_contacts__admin_details_form__telephone"]'
        end
      end
    end
  end
end
