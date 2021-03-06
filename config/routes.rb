Rails.application.routes.draw do

  health_check_routes

  devise_scope :user do
    get 'login', to: 'users/sessions#new'
    delete 'logout', to: 'users/sessions#destroy'
    post 'logout', to: 'users/sessions#destroy'
    get '/', to: 'users/sessions#default'
    post 'renew_jwt', to: 'users/sessions#renew_jwt'
    if Rails.env.test?
      # Dashboard app may not be available when testing, so spoof it
      get "/dashboard", to: 'users/sessions#default'
    end
  end

  devise_for :users, controllers: { sessions: 'users/sessions' }

end
