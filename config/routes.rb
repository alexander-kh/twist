require "constraints/subdomain_required"

Twist::Application.routes.draw do
  devise_for :users
  
  namespace :admin do
    root to: "accounts#index"
    
    resources :accounts, only: [:index, :show] do
      collection do
        post :search
        get :past_due
      end
    end
  end
  
  constraints(SubdomainRequired) do
    scope module: "accounts" do
      root to: "books#index", as: :account_root
      get "/account/choose_plan",
        to: "plans#choose",
        as: :choose_plan
      patch "/account/choose_plan",
        to: "plans#chosen"
      delete "/account/cancel",
        to: "plans#cancel",
        as: :cancel_subscription
      put "/accounts/switch_plan",
        to: "plans#switch",
        as: :switch_plan
      
      get "/billing", to: "billing#details"
      post "/billing", to: "billing#update_details"
      
      notes_routes = lambda do
        collection do
          get :completed
        end
        
        member do
          put :accept
          put :reject
          put :reopen
        end
        
        resources :comments
      end
      
      resources :books do
        member do
          post :receive
        end
      
        resources :chapters do
          resources :elements do
            resources :notes
          end
        
          resources :notes, &notes_routes
        end
      
        resources :notes, &notes_routes
      end
      
      resources :invitations, only: [:new, :create] do
        member do
          get :accept
          patch :accepted
        end
      end
      
      resources :users, only: [:index, :destroy]
    end
  end
  
  root to: "home#index"
  get "/accounts/new", to: "accounts#new", as: :new_account
  post "/accounts", to: "accounts#create", as: :accounts
  
  get 'signed_out', to: "users#signed_out"
  
  post "braintree/incoming", to: "braintree_webhooks#incoming"
end
