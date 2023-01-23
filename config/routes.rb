Rails.application.routes.draw do
  root to: 'questions#index'

  resources :users, except: %i[index]
  resource :session, only: %i[new create destroy]
  resources :questions do
    member do
      put :hide
    end
  end 
end
