class UcasContactsController < ApplicationController
  before_action do
    provider_code = params[:provider_code]
    raise "missing provider code" unless provider_code

    @provider = Provider
                  .where(recruitment_cycle_year: Settings.current_cycle)
                  .find(provider_code)
                  .first

    @provider.send_application_alerts = "none" unless @provider.send_application_alerts
  end

  def show; end

  def alerts; end

  def update_alerts
    email = provider_params["application_alert_contact"]
    email = nil if email.blank?
    email_changed = @provider.application_alert_contact != email
    permission_given = provider_params["share_with_ucas_permission"] == "1"
    require_permission = email != nil && email_changed

    if require_permission && !permission_given
      @errors = { share_with_ucas_permission: ["Please give permission to share this email address with UCAS"] }
      @provider.application_alert_contact = provider_params["application_alert_contact"]
      @provider.send_application_alerts = provider_params["send_application_alerts"]
      render :alerts
    else
      @provider.update(send_application_alerts: provider_params["send_application_alerts"],
                                  application_alert_contact: email)
      redirect_to provider_ucas_contacts_path(@provider.provider_code),
                  flash: { success: "Your changes have been saved" }
    end
  end

  def admin_contact; end

  def update_admin_contact
    name = provider_params["name"]
    email = provider_params["email"]
    telephone = provider_params["telephone"]

    name = nil if name.blank?
    email = nil if email.blank?
    telephone = nil if telephone.blank?

    permission_given = provider_params["share_with_ucas_permission"] == "1"
    require_permission = admin_contact_details_changed(name, email, telephone)

    if require_permission && !permission_given
      @errors = { share_with_ucas_permission: ["Please give permission to share this these details with UCAS"] }
      @provider.admin_contact["name"] = provider_params["name"]
      @provider.admin_contact["email"] = provider_params["email"]
      @provider.admin_contact["telephone"] = provider_params["telephone"]
      render :admin_contact
    else
      @provider.update(admin_contact: { "name" => name, "email" => email, "telephone" => telephone })
      redirect_to provider_ucas_contacts_path(@provider.provider_code),
                  flash: { success: "Your changes have been saved" }
    end
  end

private

  def provider_params
    params.require(:provider)
      .permit(:send_application_alerts, :application_alert_contact, :share_with_ucas_permission, :name, :email, :telephone)
  end

  def admin_contact_details_changed(name, email, telephone)
    @provider.admin_contact&.dig("name") != name || @provider.admin_contact.dig("email") != email || @provider.admin_contact.dig("telephone") != telephone
  end
end
