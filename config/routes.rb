Rails.application.routes.draw do
  root to: 'pages#home'

  get 'pages/terms'
  get 'pages/privacy'

  devise_for :users, path: '',
                     controllers: {registrations: 'users/registrations'},
                     path_names:  {sign_in: "login",
                                   sign_out: "logout",
                                   sign_up: "join",
                                   edit: 'settings'}

  resources :protocols
end
