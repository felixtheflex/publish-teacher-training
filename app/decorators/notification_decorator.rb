class NotificationDecorator < Draper::CollectionDecorator
  # include ActiveModel::Model
  #
  # attr_accessor :consent

  def blank_error
    errors.add(:consent, "You need to add some information")
  end

  def consent
    object.map(&:course_create).any? ? "Yes" : "No" if object.present?
  end

  private

  attr_reader :notifications
end
