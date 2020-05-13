class NotificationsController < ApplicationController
  def index
    @notifications = Notification.where(user_id: current_user["user_id"]).all
    # wip, not working
    set_consent_param if @notifications.present?
  end

  def create
    if params[:consent].nil?
      # TODO: Better Error messages once wired up to API
      flash[:error] = "Please select one option"
      redirect_to notifications_path
      return
    end

    if params.require(:consent).present?
      flash[:success] = "Your notification preferences have been saved."
      redirect_to redirect_to_path
    end
  end

private

  def redirect_to_path
    if params[:provider_code].present?
      provider_path(params[:provider_code])
    else
      root_path
    end
  end

  def set_consent_param
    params[:consent] = @notifications.map(&:course_create).any? ? "Yes" : "No"
  end
end
