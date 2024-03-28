Rails.application.routes.draw do

  root to: "welcome#index"
  get 'registrations/create'
  devise_for :users
  resources :stores

  post "new" => "registrations#create", as: :create_registration
  get "me" => "registrations#me"
  post "sign_in" => "registrations#sign_in"

  get "up" => "rails/health#show", as: :rails_health_check
  get "listing" => "products#listing"
end
