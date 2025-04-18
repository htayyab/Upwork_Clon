Rails.application.routes.draw do
  resources :jobs do
    resources :proposals, only: [:index, :create] do
      collection do
        get 'job_proposals'  # e.g., /jobs/:job_id/proposals/job_proposals
      end
    end
  end

  #route for freelancer display all proposals 
  get 'my_proposals', to: 'proposals#my_proposals'

  # Show freelancer's accepted jobs (non-nested)
  get 'freelancer_accepted_jobs', to: 'jobs#freelancer_accepted_jobs'

  # show all accepetd jobs list for client side 
  get 'client_accepted_jobs', to: 'jobs#client_accepted_jobs'


  resources :jobs do
    member do
      patch :approve_completion  # PATCH /jobs/:id/approve_completion
      patch :reject_completion   # PATCH /jobs/:id/reject_completion
    end
  end


  resources :jobs do
    member do
      patch :freelancer_complete  # PATCH /jobs/:id/freelancer_complete
    end
  end

#   resources :jobs do
#   collection do
#     get 'client_accepted' # Lists client's accepted jobs
#   end
  
#   member do
#     patch 'approve_completion'
#     patch 'reject_completion'
#   end
# end

  resources :proposals, only: [] do
    member do
      patch :accept
      patch :reject
    end
  end

  # New: All proposals for jobs posted by current client
  resources :proposals, only: [] do
    collection do
      get 'client_proposals' 
    end
  end


  get 'search', to: 'search#index'       # Displays the search form
  post 'search', to: 'search#results'    # Processes the search (or you could use get if you pref
  
  root "home#index"

  # Static/custom pages
  get "registration_options", to: "home#registration_options", as: :registration_options

  # Job routes for client (CRUD)
  resources :jobs


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
end
