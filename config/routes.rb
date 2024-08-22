Rails.application.routes.draw do
  scope :scim do
    mount Scimitar::Engine, at: '/'

    get    'Users',      to: 'users#index'
    get    'Users/:id',  to: 'users#show'
    post   'Users',      to: 'users#create'
    put    'Users/:id',  to: 'users#replace'
    patch  'Users/:id',  to: 'users#update'
    delete 'Users/:id',  to: 'users#destroy'

    get    'Groups',      to: 'groups#index'
    get    'Groups/:id',  to: 'groups#show'
    post   'Groups',      to: 'groups#create'
    put    'Groups/:id',  to: 'groups#replace'
    patch  'Groups/:id',  to: 'groups#update'
    delete 'Groups/:id',  to: 'groups#destroy'
  end
end
