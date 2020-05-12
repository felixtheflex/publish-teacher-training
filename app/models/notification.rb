class Notification < Base
  belongs_to :user, param: :user_id
  belongs_to :provider, param: :provider_code, shallow_path: true

  property :course_create
  property :course_update
end
