class OrganisationSerializer < JSONAPI::Serializable::Resource
  type "organisation"
  has_many :organisation_users

  has_many :users, through: :organisation_users
  has_many :providers

  attributes(*FactoryBot.attributes_for("organisation").keys)
end
