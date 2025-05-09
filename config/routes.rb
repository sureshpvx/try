Rails.application.routes.draw do
  
  resource :session
  resources :passwords, param: :token
  
  get 'auth/google_oauth2/callback', to: 'sessions#google_oauth2'
  
  root "home#index"
end
