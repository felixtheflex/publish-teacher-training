class Notification < Base
  belongs_to :user, param: :user_id
  belongs_to :provider, param: :provider_code, shallow_path: true

  property :course_create
  property :course_update
end

# include ActiveModel::Model
#
# attr_accessor :consent

# def blank_error
#   errors.add(:consent, "You need to add some information")
# end
