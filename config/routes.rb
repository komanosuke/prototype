Rails.application.routes.draw do
  get 'password_resets/new'
  get 'password_resets/edit'
  get 'admin_sessions/new'
  root to: 'parcom#index'

  get 'sessions/new'
  resources :schedules

  # get '/zyzw', to: 'admin#index' #（例）adminログイン画面のURLを特定されない名前にする
  get '/admin_login',   to: 'admin_sessions#new'
  post '/admin_login',   to: 'admin_sessions#create'
  delete '/admin_logout',  to: 'admin_sessions#destroy'

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  get 'admin/index'
  post 'admin/index'
  get 'admin/add'
  post 'admin/add'
  get 'admin/add_done'
  get 'admin/edit'
  post 'admin/edit'
  patch 'admin/edit'
  get 'admin/delete'
  post 'admin/delete'
  get 'admin/delete_done'
  get 'admin/command'

  get 'index', to: 'parcom#index'
  get 'beginners', to: 'parcom#beginners'
  get 'help', to: 'parcom#help'
  get 'privacy', to: 'parcom#privacy'
  get 'terms', to: 'parcom#terms'
  get 'article', to: 'parcom#article'
  get 'free_wifi', to: 'parcom#free_wifi'
  get 'news', to: 'parcom#news'
  get 'park/:park_id', to: 'parcom#park'
  get 'profile/:park_id', to: 'parcom#profile'
  get 'review/:park_id', to: 'parcom#review'
  get 'parcom/get_data'
  get 'controlpanel/:park_id/:bench_id', to: 'parcom#controlpanel'
  post 'controlpanel/:park_id/:bench_id', to: 'parcom#controlpanel'
  post 'parcom/create'
  resources :parcom, only: [:new, :create]

  get 'parcom/post_data'
  post 'parcom/post_data'
  
  get '/', to: 'parcom#index'
  post '/', to: 'parcom#index'
  get 'index', to: 'parcom#index'
  get 'register', to: 'user#register'
  post 'register', to: 'user#register'
  get 'user/create', to: 'user#create'
  post 'user/create', to: 'user#create'
  get 'account', to: 'user#account'
  patch 'account', to: 'user#account'
  get 'changemail', to: 'user#changemail'
  patch 'changemail', to: 'user#changemail'
  get 'changepwd', to: 'user#changepwd'
  post 'changepwd', to: 'user#changepwd'
  patch 'changepwd', to: 'user#changepwd'
  get 'signup_success', to: 'user#signup_success'
  post 'signup_success', to: 'user#signup_success'
  get 'signupmail_success', to: 'user#signupmail_success'
  get 'signupmail', to: 'user#signupmail'
  post 'signupmail', to: 'user#signupmail'
  get 'signupmail_error', to: 'user#signupmail_error'
  get 'user/signupmail_confirm'
  post 'user/signupmail_confirm'
  post 'user/back'
  get 'changepwd_error', to: 'user#changepwd_error'
  resources :users, except: [:new]
  resources :account_activations, only: [:edit]
  resources :password_resets, only: [:new, :create, :edit, :update]

  get 'parkinfo_edit/:park_id', to: 'park#parkinfo_edit'
  post 'parkinfo_edit/:park_id', to: 'park#parkinfo_edit'
  patch 'parkinfo_edit/:park_id', to: 'park#parkinfo_edit'
  get 'products/:park_id', to: 'park#products'
  resources :park, only: [:new, :create]
  
  get 'shortcut/:park_id', to: 'shortcut#index'
  post 'shortcut/create', to: 'shortcut#create'
  post 'shortcut/delete/:shortcut_id', to: 'shortcut#delete'

  get 'contacts', to: 'contacts#new'
  resources :contacts, only: [:create]
  post 'contacts/confirm', to: 'contacts#confirm', as: 'confirm'
  post 'contacts/back', to: 'contacts#back', as: 'back'
  get 'contacts/done', to: 'contacts#done', as: 'done'

  get 'analyze/:park_id', to: 'analyze#index'

  get '*not_found' => 'application#routing_error'
  post '*not_found' => 'application#routing_error'

  require 'sidekiq/web'
  mount Sidekiq::Web, at: "/sidekiq"
  
end
