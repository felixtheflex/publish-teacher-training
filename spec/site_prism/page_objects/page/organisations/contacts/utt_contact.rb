module PageObjects
  module Page
    module Organisations
      module Contacts
        class UTTContact < PageObjects::Base
          set_url "/organisations/{provider_code}/ucas-contacts/utt-contact"

          element :name, '[data-qa="contact__name"]'
          element :email, '[data-qa="contact__email"]'
          element :telephone, '[data-qa="contact__telephone"]'
          element :share_with_ucas_permission, '[data-qa="contact__share_with_ucas_permission"]'
          element :save, '[data-qa="contact__save"]'
        end
      end
    end
  end
end
