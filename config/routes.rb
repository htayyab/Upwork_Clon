Rails.application.routes.draw do
  
  #route for freelancer display all proposals send 
  get 'my_proposals', to: 'proposals#my_proposals'
  # Show freelancer's accepted jobs 
  get 'freelancer_accepted_jobs', to: 'jobs#freelancer_accepted_jobs'
  # show all accepetd jobs list for client side 
  get 'client_accepted_jobs', to: 'jobs#client_accepted_jobs'

  #Jobs Controller Routes 
  resources :jobs do
    member do
      patch :approve_completion  # PATCH /jobs/:id/approve_completion
      patch :reject_completion   # PATCH /jobs/:id/reject_completion
      patch :freelancer_complete  # PATCH /jobs/:id/freelancer_complete
    end
    resources :proposals, only: [:index, :create]  # nested under jobs
  end

  #Proposals Controller All routes 
  resources :proposals do
    member do
      patch :accept     # PATCH /proposals/:id/accept
      patch :reject     # PATCH /proposals/:id/reject
    end
  
    collection do
      get :client_proposals  # GET /proposals/client_proposals
    end
  end

  

  #Jobs Search Controller Routes
  get 'search', to: 'search#index'       # Displays the search form
  post 'search', to: 'search#results'    # Processes the search (or you could use get if you pref
  
  # Devise routes for user authentication
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  # Custom Devise routes (friendly URLs)
  devise_scope :user do
    get    'login',    to: 'users/sessions#new',        as: :login_user
    delete 'logout',   to: 'users/sessions#destroy',    as: :logout_user
    get    'register', to: 'users/registrations#new',   as: :signup_user
    get    'update',   to: 'users/registrations#edit',  as: :update_user
  end

  # route for role selection page 
  get "registration_options", to: "home#registration_options", as: :registration_options
  #home page route
  root "home#index"
end
