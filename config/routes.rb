Rails.application.routes.draw do
  devise_for :users
  resources :stores
  root to: "welcome#index"

  get "up" => "rails/health#show", as: :rails_health_check
  get "listing" => "products#listing"
end
