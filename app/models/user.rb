class User < Base
  custom_endpoint :accept_transition_screen, on: :member, request_method: :patch

  def self.member(id)
    new(id: id)
  end
end