Rails.application.routes.draw do
  authenticated :user do
    root to: 'users#index', as: :authenticated_root
  end

  unauthenticated do
    root to: 'main#index'
  end

  get 'main/terms'
  get 'main/privacy'

  devise_for :users, path: '',
                     controllers: {registrations: 'users/registrations'},
                     path_names:  {sign_in: "login",
                                   sign_out: "logout",
                                   sign_up: "join",
                                   edit: 'settings'}

  resources :users, path: '', only: [:show]
end
