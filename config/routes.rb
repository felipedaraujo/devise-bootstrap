Rails.application.routes.draw do
  resources :protocols
  get 'search', to: 'search#search'
end
