Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#index"

  resource :profile, only: [:show, :edit, :update]
  resources :budgets, only: [:index, :update] do
    resources :monthly_expenses, only: [:create, :destroy] do
      collection do
        post :batch_create
      end
    end
    resources :receipt_scans, only: [:create]
  end
  resources :fixed_expenses, only: [:index, :create, :update, :destroy]
  resources :roadmaps, only: [:index, :new, :create, :show, :destroy] do
    resources :chats, only: [:create]
  end
  resources :tasks, only: [:update]
end
