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
  get 'admin/edit'
  get 'admin/delete'

  get 'panels/index'
  get 'panels', to: 'panels#index'
  post 'panels/index'
  post 'panels', to: 'panels#index'

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

  get 'parcom/post_data'
  post 'parcom/post_data'
  


  get 'user/index'

  get 'user/account'
  get 'user/changemail'
  get 'user/changepwd'
  get 'user/login'
  get 'user/signup_success'
  get 'user/signup'
  get 'user/signupmail_success'
  get 'user/signupmail'

  get 'park/parkinfo_edit'
  get 'park/products'
  
  get 'shortcut/shortcut'
  
end
