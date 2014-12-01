require 'sidekiq/web'

Rails.application.routes.draw do

  resources :sites do
    resources :scans
    resources :rules
  end

  devise_for :users
  scope '/admin' do
    resources :users, as: 'users'
  end

  root to: redirect('/sites', status: 302)
  
  # authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  # end
end
