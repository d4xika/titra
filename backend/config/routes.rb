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

    resources :projects, only: [ :index, :show, :create, :update, :destroy ], param: :name

    resources :sessions, only: [ :index, :create, :update, :destroy ] do
      collection do
        get :summary
      end
    end
  end
end
