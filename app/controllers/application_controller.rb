class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, except: :not_found
  rescue_from JsonApiClient::Errors::NotAuthorized, with: :render_unauthorized
  rescue_from JsonApiClient::Errors::AccessDenied, with: :handle_access_denied

  before_action :authenticate

  def not_found
    respond_with_error(template: "errors/not_found", status: :not_found, error_text: "Resource not found")
  end

  def render_unauthorized
    respond_with_error(template: "errors/unauthorized", status: :unauthorized, error_text: "Unauthorized request")
  end

  def handle_access_denied(exception)
    if user_has_not_accepted_terms(exception.env.body)
      redirect_to accept_terms_path
    else
      respond_with_error(template: "errors/forbidden", status: :forbidden, error_text: "Forbidden request")
    end
  end

  helper_method :current_user

  def current_user
    if session[:auth_user]
      @current_user ||= session[:auth_user]
    elsif development_mode_auth?
      if (email = authenticate_with_http_basic { |u, p| p == development_mode_password(u) && u })
        setup_development_mode_session(email)
      end
    end
  end

  def log_safe_current_user(reload: false)
    if @log_safe_current_user.nil? || reload
      @log_safe_current_user = current_user.dup
      email = @log_safe_current_user["info"]&.fetch("email", "")
      @log_safe_current_user.delete("info")
      @log_safe_current_user["email_md5"] = Digest::MD5.hexdigest(email)
    end
    @log_safe_current_user
  end

  def development_mode_auth?
    Settings.key?(:authorised_users)
  end

  def authenticate
    if current_user.present?
      logger.debug { "Authenticated user session found " + log_safe_current_user.to_s }

      assign_sentry_contexts
      assign_logstash_contexts
      add_token_to_connection
      set_has_multiple_providers

      if current_user["user_id"].blank?
        set_user_session
        Raven.user_context(id: current_user["user_id"])
        logger.debug { "User session set. " + log_safe_current_user(reload: true).to_s }
      end

    else
      logger.debug("Authenticated user session not found " + {
                     redirect_back_to: request.path,
                   }.to_s)
      if development_mode_auth?
        request_http_basic_authentication("Development Mode")
      else
        session[:redirect_back_to] = request.path
        redirect_to "/signin"
      end
    end
  end

  def current_user_info
    current_user["info"]
  end

  def current_user_dfe_signin_id
    current_user["uid"]
  end

  def set_has_multiple_providers
    @has_multiple_providers = has_multiple_providers?
  end

  def has_multiple_providers?
    provider_count = session.to_hash.dig("auth_user", "provider_count")
    provider_count.nil? || provider_count > 1
  end

private

  def development_mode_password(email)
    Rails.env.development? && Settings&.authorised_users&.[](email)
  end

  def setup_development_mode_session(email)
    session[:auth_user] = HashWithIndifferentAccess.new(
      uid: SecureRandom.uuid,
      info: HashWithIndifferentAccess.new(
        email: email,
        # We don't have the user's name here, but it doesn't matter what we send
        # to the backend since we're in development mode now anyway, right??!
        first_name: "Development",
        last_name: "User",
      ),
      credentials: HashWithIndifferentAccess.new(
        id_token: "id_token",
      ),
    )
  end

  def user_has_not_accepted_terms(response_body)
    return false unless response_body.is_a?(Hash)

    response_body.key?("meta") &&
      response_body["meta"]["error_type"] == "user_not_accepted_terms_and_conditions"
  end

  def respond_with_error(template:, status:, error_text:)
    respond_to do |format|
      format.html { render template, status: status }
      format.json { render json: { error: error_text }, status: status }
      format.all { render status: status, body: nil }
    end
  end

  def set_user_session
    logger.debug {
      "Creating new session for user " + {
        email_md5: log_safe_current_user["email_md5"],
        signin_id: current_user_dfe_signin_id,
      }.to_s
    }

    # TODO: we should return a session object here with a 'user' attached to id.
    user = Session.create(first_name: current_user_info[:first_name],
                          last_name: current_user_info[:last_name])
    session[:auth_user]["user_id"] = user.id
    session[:auth_user]["state"] = user.state

    add_provider_count_cookie

    user
  end

  def add_provider_count_cookie
    begin
      session[:auth_user][:provider_count] =
        Provider.where(recruitment_cycle_year: Settings.current_cycle).all.size
    rescue StandardError => e
      logger.error "Error setting the provider_count cookie: #{e.class.name}, #{e.message}"
    end
  end

  def add_token_to_connection
    payload = {
      email:           current_user_info["email"].to_s,
      first_name:      current_user_info["first_name"].to_s,
      last_name:       current_user_info["last_name"].to_s,
      sign_in_user_id: current_user_dfe_signin_id,
    }
    token = JWT.encode(payload,
                       Settings.manage_backend.secret,
                       Settings.manage_backend.algorithm)

    Thread.current[:manage_courses_backend_token] = token
  end

  def assign_sentry_contexts
    Raven.user_context(id: current_user["user_id"])
    Raven.tags_context(sign_in_user_id: current_user.fetch("uid"))
  end

  def assign_logstash_contexts
    Thread.current[:logstash] ||= {}
    Thread.current[:logstash][:user_id] = current_user["user_id"]
    Thread.current[:logstash][:sign_in_user_id] = current_user["uid"]
  end
end
