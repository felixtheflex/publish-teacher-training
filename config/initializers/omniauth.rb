Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer,
           fields: %i[email first_name last_name],
           uid_field: :email
end

module OmniAuth
  module Strategies
    class OpenIDConnect
      def authorize_uri
        client.redirect_uri = redirect_uri
        opts = {
          response_type: options.response_type,
          scope: options.scope,
          state: new_state,
          nonce: (new_nonce if options.send_nonce),
          hd: options.hd,
          prompt: :consent,
        }
        client.authorization_uri(opts.reject { |_, v| v.nil? })
      end

      def callback_phase
        error = request.params["error_reason"] || request.params["error"]
        if error == "sessionexpired"
          redirect("/signin")
        elsif error
          raise CallbackError.new(request.params["error"], request.params["error_description"] || request.params["error_reason"], request.params["error_uri"])
        elsif request.params["state"].to_s.empty? || request.params["state"] != stored_state
          # Monkey patch: Ensure a basic 401 rack response with no body or header isn't served
          # return Rack::Response.new(['401 Unauthorized'], 401).finish
          redirect("/auth/failure")
        elsif !request.params["code"]
          fail!(:missing_code, OmniAuth::OpenIDConnect::MissingCodeError.new(request.params["error"]))
        else
          options.issuer = issuer if options.issuer.blank?
          discover! if options.discovery
          client.redirect_uri = redirect_uri
          client.authorization_code = authorization_code
          access_token
          super
        end
      rescue CallbackError => e
        fail!(:invalid_credentials, e)
      rescue ::Timeout::Error, ::Errno::ETIMEDOUT => e
        fail!(:timeout, e)
      rescue ::SocketError => e
        fail!(:failed_to_connect, e)
      rescue Rack::OAuth2::Client::Error => e
        Rails.logger.error "Auth failure, is Settings.dfe_signin.secret correct? #{e}"
        raise
      end
    end
  end
end

class OmniAuth::Strategies::Dfe < OmniAuth::Strategies::OpenIDConnect; end

if Settings.dfe_signin.issuer.present?
  dfe_sign_in_issuer_uri = URI.parse(Settings.dfe_signin.issuer)
  options = {
    name: :dfe,
    discovery: true,
    response_type: :code,
    client_signing_alg: :RS256,
    scope: %i[openid profile email offline_access],
    prompt: %i[consent],
    client_options: {
      port: dfe_sign_in_issuer_uri.port,
      scheme: dfe_sign_in_issuer_uri.scheme,
      host: dfe_sign_in_issuer_uri.host,
      identifier: Settings.dfe_signin.identifier,
      secret: Settings.dfe_signin.secret,
      redirect_uri: "#{Settings.dfe_signin.base_url}/auth/dfe/callback",
      authorization_endpoint: "/auth",
      jwks_uri: "/certs",
      token_endpoint: "/token",
      userinfo_endpoint: "/me",
    },
  }

  Rails.application.config.middleware.use OmniAuth::Strategies::OpenIDConnect, options

  class DfeSignIn
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)

      if request.path == "/auth/failure"
        response = Rack::Response.new
        response.redirect("/401")
        response.finish
      elsif request.path == "/auth/dfe/callback" && request.params.empty? && !OmniAuth.config.test_mode
        response = Rack::Response.new
        response.redirect("/dfe/sessions/new")
        response.finish
      else
        @app.call(env)
      end
    rescue ActionController::InvalidAuthenticityToken
      response = Rack::Response.new
      response.redirect("/signin")
      response.finish
    end
  end

  Rails.application.config.middleware.insert_before OmniAuth::Strategies::OpenIDConnect, DfeSignIn
end
