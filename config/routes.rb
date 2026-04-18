Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#index"

  resource :profile, only: [:show, :edit, :update]
  resources :roadmaps, only: [:index, :new, :create, :show, :destroy] do
    resources :chats, only: [:create]
  end
  resources :tasks, only: [:update]
end
