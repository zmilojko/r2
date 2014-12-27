require 'sidekiq/web'

Rails.application.routes.draw do

  resources :tags

  resources :sites do
    resources :scans do
      get 'report', on: :collection
      post 'newseed', on: :collection
    end
    resources :rules
  end

  devise_for :users
  scope '/admin' do
    resources :users, as: 'users'
  end

  root to: "home#index"
  
  # authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
    # mount Genghis::Server.new, :at => '/genghis'
  # end
end
