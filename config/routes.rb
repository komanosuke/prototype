Rails.application.routes.draw do
  root to: 'others#link'

  get 'sessions/new'
  resources :schedules
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get '/', to: 'others#link'
  post '/', to: 'others#link'

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

  get 'parcom/index'
  get 'parcom/beginners'
  get 'parcom/contact'
  get 'parcom/help'
  get 'parcom/privacy'
  get 'parcom/terms'
  get 'parcom/article'
  get 'parcom/free_wifi'
  get 'parcom/news'
  get 'parcom/park'
  get 'parcom/profile'
  get 'parcom/review'
  get 'parcom/controlpanel'
  post 'parcom/controlpanel'
  post 'parcom/create'
  resources :parcom, only: [:new, :create]

  get 'parcom/post_data'
  post 'parcom/post_data'
  


  get 'user/index'
  get 'user/register'
  post 'user/register'
  get 'user/account'
  patch 'user/account'
  get 'user/changemail'
  patch 'user/changemail'
  get 'user/changepwd'
  get 'user/signup_success'
  get 'user/signup'
  get 'user/signupmail_success'
  get 'user/signupmail'
  post 'user/signupmail'
  get 'user/forgetpwd'
  get 'user/signupmail_error'
  get 'user/signupmail_confirm'

  get 'park/parkinfo_edit'
  get 'park/products'
  
  get 'shortcut/shortcut'


  resources :contacts, only: [:new, :create]
  post 'contacts/confirm', to: 'contacts#confirm', as: 'confirm'
  post 'contacts/back', to: 'contacts#back', as: 'back'
  get 'done', to: 'contacts#done', as: 'done'


  get '*not_found' => 'application#routing_error'
  post '*not_found' => 'application#routing_error'
  
end
