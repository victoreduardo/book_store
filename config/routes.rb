Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "books#index"

  # Autenticação
  get    "/login",    to: "sessions#new",     as: :login
  post   "/login",    to: "sessions#create"
  delete "/logout",   to: "sessions#destroy",  as: :logout

  # Cadastro
  get  "/signup", to: "users#new",    as: :signup
  post "/users",  to: "users#create"
  get  "/profile", to: "users#profile", as: :profile

  # Livros e comentários
  resources :books, only: [:index, :show] do
    resources :comments, only: [:create, :destroy]
  end

  # Busca — endpoint com SQLi
  get "/search", to: "books#search", as: :search

  # Pedidos — endpoint com IDOR
  resources :orders, only: [:index, :show, :create]

  # Admin
  namespace :admin do
  end
  get  "/admin",        to: "admin#dashboard", as: :admin_dashboard
  get  "/admin/users",  to: "admin#users",     as: :admin_users
  get  "/admin/books",  to: "admin#books",     as: :admin_books
end
