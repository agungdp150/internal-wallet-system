# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: %i[index show create update destroy]
    end
  end

  namespace :api do
    namespace :v1 do
      resources :stocks, only: %i[index show create update destroy]
    end
  end

  namespace :api do
    namespace :v1 do
      resources :teams, only: %i[index show create update destroy]
    end
  end

  namespace :api do
    namespace :v1 do
      resources :transactions, only: %i[index show create]
    end
  end

  namespace :api do
    namespace :v1 do
      resources :wallets, only: %i[index show]
    end
  end

  namespace :api do
    namespace :v1 do
      post 'login', to: 'auth#create'
      delete 'logout', to: 'auth#destroy'
    end
  end
end
