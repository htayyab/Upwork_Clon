Rails.application.routes.draw do
  

  #route for freelancer display all proposals send 
  get 'my_proposals', to: 'proposals#my_proposals'

  # Show freelancer's accepted jobs 
  get 'freelancer_accepted_jobs', to: 'jobs#freelancer_accepted_jobs'

  # show all accepetd jobs list for client side 
  get 'client_accepted_jobs', to: 'jobs#client_accepted_jobs'


  resources :jobs do
    member do
      patch :approve_completion  # PATCH /jobs/:id/approve_completion
      patch :reject_completion   # PATCH /jobs/:id/reject_completion
      patch :freelancer_complete  # PATCH /jobs/:id/freelancer_complete
    end
  end

  #Accept or Reject the Proposal options for client 
  resources :proposals, only: [] do
    member do
      patch :accept
      patch :reject
    end
  end

  #clients see all proposals on their own specific job 
  resources :proposals, only: [] do
    collection do
      get 'client_proposals' 
    end
  end


  get 'search', to: 'search#index'       # Displays the search form
  post 'search', to: 'search#results'    # Processes the search (or you could use get if you pref
  

  # Job routes for client (CRUD)
  resources :jobs

   # Static/custom pages
   get "registration_options", to: "home#registration_options", as: :registration_options

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

  root "home#index"
end
