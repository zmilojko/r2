Rails.application.routes.draw do

  resources :sites do
    resources :scans
  end

  devise_for :users
  scope '/admin' do
    resources :users, as: 'users'
  end

  root to: redirect('/sites', status: 302)
end
