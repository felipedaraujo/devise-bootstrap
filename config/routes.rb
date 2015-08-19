Rails.application.routes.draw do
  get 'pages/home'

  resources :protocols
end
