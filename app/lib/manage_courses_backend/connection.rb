module ManageCoursesBackend
  module Connection
    EMPTY_RESPONSE = '{}'.freeze

  private

    def connection(token)
      Faraday.new base_url do |connection|
        connection.use FaradayMiddleware::OAuth2, token, token_type: :bearer
        connection.adapter Faraday.default_adapter
      end
    end

    def base_url
      Addressable::URI.parse("#{Settings.manage_backend.base_url}/api/v2")
    end
  end
end
