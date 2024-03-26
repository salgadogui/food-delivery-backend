Rails.application.routes.draw do
  get 'registrations/create'
  devise_for :users
  resources :stores
  root to: "welcome#index"

  post "new" => "registrations#create", as: :create_registration
  post "me" => "registrations#me"
  post "sign_in" => "registrations#sign_in"

  get "up" => "rails/health#show", as: :rails_health_check
  get "listing" => "products#listing"
end
