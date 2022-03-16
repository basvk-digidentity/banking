Rails.application.routes.draw do
  resources :accounts, only: [:index, :show] do
    resource :transfer, only: [:new, :create]
  end

  match '/login'   => 'sessions#login', via: [:get, :post]
  delete '/logout' => 'sessions#logout'

  root "accounts#index"
end
