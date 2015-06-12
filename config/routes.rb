MultigroupEvents::Application.routes.draw do

  match '/auth/:provider/callback', to: 'authentications#create', via: 'get'

  resources :authentications
  resources :password_resets
  resources :profiles 

  resources :users, except: [:show] do
    resources :verify_emails, only: [:new, :create]
    resources :reset_verify_emails, only: [:new, :create]
  end

  get 'events/new_type/:type', to: 'events#new', as: 'new_event_type'
  get 'events/:id/rsvp_print', to: 'events#rsvp_print', as: 'show_event_rsvp_print'
  get 'events/list/:tab', to: 'events#index_tab', as: 'events_tab', 
       constraints: { tab: Regexp.new("#{Event.event_tab_regex}", true) }
   #    constraints: lambda{ |request| request.parms[:tab].match('foo.bar')}
  resources :events 
  post 'events/:id/reload', to: 'events#reload_api', as: 'reload_api'

 # get 'calendar/show', to: 'calendar#show', as: 'calendar'

 # get 'events/upcomming', to: 'events#list', as: 'show_upcomming_events'
 # get 'events/past', to: 'events#list', as: 'show_past_events'
 # get 'events/calendar', to: 'events#list', as: 'show_event_calendar'

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

  get 'user_roles/:id/edit', to: "change_user_roles#edit", as: :edit_user_roles
  match ':id/user_roles', to: "change_user_roles#update", as: :user_roles, via: ['put', 'patch']

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
  get '/user_login_status', to: "sessions#login_status", as: :login_status, :defaults => { :format => 'json' }

  root  'static_pages#home'
  match '/signup',  to: 'users#new', via: 'get'
  match '/signin',  to: 'sessions#new',         via: 'get'
  match '/signout', to: 'sessions#destroy',     via: 'delete'

  match '/home', to: 'static_pages#home', via: 'get'
  match '/help', to: 'static_pages#help', via: 'get'
  match '/about', to: 'static_pages#about', via: 'get'
  match '/contact', to: 'static_pages#contact', via: 'get'
  match '/error', to: 'static_pages#error', via: 'get'

  get '/events/templates/:page', to: 'static_pages#event_js'

  match '~:id' => 'profiles#show', :as => :show_profile, via: 'get', :constraints => { :username => /[A-Za-z0-9_\.]+/ }

end
