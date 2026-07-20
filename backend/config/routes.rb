Rails.application.routes.draw do
  namespace :api do
    get "up" => "rails/health#show", as: :rails_health_check
    get "/csrf", to: "application#csrf_token"

    resources :users, only: [] do
      collection do
        get :is_logged_in
        post :login
        post :register
        put :logout
      end
    end
  end
end
