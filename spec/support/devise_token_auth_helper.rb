module DeviseTokenAuthHelper
  module Controller
    def set_authentication_headers_for(user)
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @request.headers.merge! user.create_new_auth_token
    end
  end
end

RSpec.configure do |config|
  config.include DeviseTokenAuthHelper::Controller, type: :controller
end
