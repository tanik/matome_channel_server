require 'sidekiq/web'

Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  resources :categories, only: [:index]
  resources :boards, only: [:index, :show, :create] do
    member do
      put :favorite
    end
    resources :comments, only: [:index, :show, :create] do
      member do
        put :favorite
      end
    end
  end

  # sidekiq
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_USERNAME"])) &
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_PASSWORD"]))
  end
  mount Sidekiq::Web, at: "/sidekiq"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  mount ActionCable.server => '/cable'
end
