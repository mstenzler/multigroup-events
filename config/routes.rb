RailsTemplate::Application.routes.draw do

  match '/auth/:provider/callback', to: 'authentications#create', via: 'get'

  resources :authentications
  resources :password_resets
  resources :profiles 

  resources :users, except: [:show] do
    resources :verify_emails, only: [:new, :create]
    resources :reset_verify_emails, only: [:new, :create]
#    resources :change_usernames, only: [:edit, :update], shallow: true
#    resources :change_emails, only: [:edit, :update], shallow: true
#    resources :change_avatars, only: [:edit, :update], shallow: true
  end

  get '/users/:id', to: "profiles#show"

#  resources :change_usernames, only: [:edit, :update]

  get 'user_location/edit', to: "user_locations#edit", as: :edit_user_location
  post 'user_location', to: "user_locations#update", as: :user_location
 
  get 'user_avatar/edit', to: "change_avatars#edit", as: :edit_user_avatar
  match 'user_avatar', to: "change_avatars#update", as: :user_avatar, via: ['put', 'patch']

  get 'username/edit', to: "change_usernames#edit", as: :edit_username
  match 'username', to: "change_usernames#update", as: :username, via: ['put', 'patch']

  get 'user_email/edit', to: "change_emails#edit", as: :edit_user_email
  match 'user_email', to: "change_emails#update", as: :user_email, via: ['put', 'patch']

  post '/profiles/:id/enable_personal_on', to: "profiles#enable_personal_on",
  as: :enable_personal_profile_on
  resource :personal_profile, except: [:new, :create] do
    member do
      get 'edit_wants'
    end
  end

  get '/users/:user_id/verify_email_token/:verify_token', 
       to: "verify_emails#create", as: 'verify_email_token'
 
  resources :sessions, only: [:new, :create, :destroy]

  root  'static_pages#home'
  match '/signup',  to: 'users#new', via: 'get'
  match '/signin',  to: 'sessions#new',         via: 'get'
  match '/signout', to: 'sessions#destroy',     via: 'delete'

  match '/home', to: 'static_pages#home', via: 'get'
  match '/help', to: 'static_pages#help', via: 'get'
  match '/about', to: 'static_pages#about', via: 'get'
  match '/contact', to: 'static_pages#contact', via: 'get'
  match '/error', to: 'static_pages#error', via: 'get'

  match '~:id' => 'profiles#show', :as => :show_profile, via: 'get', :constraints => { :username => /[A-Za-z0-9_\.]+/ }

end
