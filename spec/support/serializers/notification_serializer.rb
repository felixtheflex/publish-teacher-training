class NotificationSerializer < JSONAPI::Serializable::Resource
  type "notifications"

  belongs_to :provider
  belongs_to :user

  attributes(*FactoryBot.attributes_for("notification").keys)
end
