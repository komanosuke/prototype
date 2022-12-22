Rails.application.routes.draw do
  resources :schedules
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get '/', to: 'others#link'
  post '/', to: 'others#link'

  get 'panels/index'
  get 'panels', to: 'panels#index'
  post 'panels/index'
  post 'panels', to: 'panels#index'

  get 'panels/say'
  post 'panels/say'
  get 'panels/show'
  post 'panels/show'
  get 'panels/done'

  get 'others/index'
  get 'others/beginners'
  get 'others/contact'
  get 'others/help'
  get 'others/privacy'
  get 'others/terms'
  get 'others/account'
  get 'others/article'
  get 'others/changemail'
  get 'others/changepwd'
  get 'others/free_wifi'
  get 'others/login'
  get 'others/news'
  get 'others/park'
  get 'others/parkinfo_edit'
  get 'others/products'
  get 'others/profile'
  get 'others/review'
  get 'others/shortcut'
  get 'others/signup_success'
  get 'others/signup'
  get 'others/signupmail_success'
  get 'others/signupmail'
end
