class Base < JsonApiClient::Resource
  # This connection class grabs the bearer token from the thread key-value
  # store and adds it to our connection. This token was saved there for us when
  # the user was first authenticated.
  class MCBConnection < JsonApiClient::Connection
    def run(request_method, path, params: nil, headers: {}, body: nil)
      authorization = "Bearer #{RequestStore.store[:manage_courses_backend_token]}"

      super(
        request_method,
        path,
        params: params,
        headers: headers.update(
          "Authorization" => authorization,
          "X-Request-Id" => RequestStore.store[:request_id],
        ),
        body: body
      )
    end
  end

  include Draper::Decoratable

  self.site = "#{Settings.manage_backend.base_url}/api/v2/"
  self.paginator = JsonApiClient::Paginating::NestedParamPaginator
  self.connection_class = MCBConnection

private

  def post_request(path)
    post_options = {
      body: { data: { attributes: {}, type: self.class.to_s.downcase } },
      params: request_params.to_params,
    }

    self.last_result_set = self.class.requestor.__send__(
      :request, :post, post_base_url + path, post_options
    )

    if last_result_set.has_errors?
      fill_errors # Inherited from JsonApiClient::Resource
      false
    else
      errors.clear if errors
      true
    end
  end
end
