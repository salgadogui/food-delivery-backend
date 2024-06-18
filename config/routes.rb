Rails.application.routes.draw do
  root to: "welcome#index"
  get 'registrations/create'
  devise_for :users
  
  get "products" => "products#index"
  get "orders" => "orders#index"
  post "new" => "registrations#create", as: :create_registration
  get "me" => "registrations#me"
  post "sign_in" => "registrations#sign_in"

  get "up" => "rails/health#show", as: :rails_health_check

  resources :stores do
    resources :products
    resources :orders do
      member do 
        get 'status', to: 'orders#status'
        patch 'update_status'
        post 'confirm_order'
      end
    end

    member do
      patch :toggle_state
    end
  end
end
