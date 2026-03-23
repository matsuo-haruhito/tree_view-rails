Rails.application.routes.draw do
  get 'items/new'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  authenticated :user do
    root 'root#index'
  end

  devise_scope :user do
    get '/', to: 'users/sessions#new'
  end

  devise_for :users, only: [:sign_in, :sign_out, :session], controllers: {
    sessions: 'users/sessions'
  }

  resource :profile, only: [:edit, :update]
  resources :notices, only: [:index]

  resources :items do
    member do
      get "show_descendants", defaults: { format: :turbo_stream } #GETメソッドで更新したい時は、フォーマットを明記？https://stackoverflow.com/questions/67309874/turbo-stream-format-not-being-sent-anymore
      get 'remove_descendants', defaults: { format: :turbo_stream }
    end
  end

  resources :machines, except: [:show] do
    collection do
      get 'show_descendants', defaults: { format: :turbo_stream }
      get 'remove_descendants', defaults: { format: :turbo_stream }
    end
  end
  resources :units, except: [:index, :show]
  resources :parts, except: [:index, :show]
  resources :materials, except: [:index, :show]

  namespace :settings do
    resources :users, except: [:show]
    resources :notices, except: [:show]
  end

  namespace :api do
    namespace :web do
      resources :users, only: [:index]
      resources :plants, only: [:index]
    end

    namespace :v1 do
      resource :login, only: [:create]
      resource :user, only: [], module: :user do
        resource :password, only: [:update]
      end
    end
  end
end
