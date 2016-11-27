Rails.application.routes.draw do
  # The root page is kind of dynamic
  root 'meta_welcome#index'

  if Rails.env.development?
    get '/sandbox' => 'sandbox#index'
    get '/sandbox/*template' => 'sandbox#show'
  end

  # Admin module
  namespace :gobierto_admin, as: :admin do
    get '/' => 'welcome#index', as: :root
    get '/login' => 'sessions#new'

    resource :sessions, only: [:new, :create, :destroy]
    resources :sites, only: [:index, :new, :create, :edit, :update, :destroy]

    namespace :sites do
      resource :sessions, only: [:create, :destroy]
    end

    resources :admins, only: [:index, :show, :new, :create, :edit, :update]

    namespace :admin do
      resource :invitations, only: [:new, :create]
      resource :confirmations, only: [:new, :create, :show]
      resource :invitation_acceptances, only: [:show]
      resource :passwords, only: [:new, :create, :edit, :update]
    end

    resources :users, only: [:index, :show, :edit, :update] do
      resource :welcome_messages, only: [:create], controller: "users/welcome_messages"
      resource :passwords, only: [:new, :create], controller: "users/passwords"
    end

    namespace :census do
      resource :imports, only: [:new, :create]
    end

    resources :activities, only: [:index]
  end

  localized do
    # User module
    namespace :user do
      constraints GobiertoSiteConstraint.new do
        get '/' => 'welcome#index', as: :root
        get '/login' => 'sessions#new'
        get '/signup' => 'registrations#new'

        resource :sessions, only: [:new, :create, :destroy]
        resource :registrations, only: [:new, :create]
        resource :confirmations, only: [:new, :create, :show]
        resource :passwords, only: [:new, :create, :edit, :update]
        resource :census_verifications, only: [:show, :new, :create], path: :verifications
      end
    end

    # Gobierto Budgets module
    namespace :gobierto_budgets, path: '', module: 'gobierto_budgets' do
      constraints GobiertoSiteConstraint.new do
        get 'site' => 'sites#show'

        # legal pages (TODO: we should merge them)
        get 'privacy' => 'pages#privacy'
        get 'legal' => 'pages#legal'
        get 'cookie_warning' => 'pages#cookie_warning'

        resources :featured_budget_lines, only: [:show]

        get 'budgets/summary(/:year)' => 'budgets#index', as: :budgets
        get 'budgets/budget_lines/:year/:area_name/:kind' => 'budget_lines#index', as: :budget_lines
        get 'budgets/budget_lines/:id/:year/:area_name/:kind' => 'budget_lines#show', as: :budget_line
        get 'budget_line_descendants/:year/:area_name/:kind' => 'budget_line_descendants#index', as: :budget_line_descendants
        get 'budgets/execution(/:year)' => 'budgets_execution#index', as: :budgets_execution
        get 'budgets/treemap(/:year)' => 'budget_lines#treemap', as: :budget_lines_treemap

        # TODO: move to an API > move to the big indexer
        get 'all_categories/:slug/:year' => 'search#all_categories', as: :search_all_categories

        namespace :api do
          get '/categories' => 'categories#index'
          get '/categories/:area/:kind' => 'categories#index'
          get '/data/widget/budget/:ine_code/:year/:code/:area/:kind' => 'data#budget', as: :data_budget
          get '/data/widget/budget_per_inhabitant/:ine_code/:year/:code/:area/:kind' => 'data#budget_per_inhabitant', as: :data_budget_per_inhabitant
          get '/data/lines/:ine_code/:year/:what' => 'data#lines', as: :data_lines
          get '/data/lines/budget_line/:ine_code/:year/:what/:kind/:code/:area' => 'data#lines', as: :data_lines_budget_line
          get '/data/widget/budget_execution_deviation/:ine_code/:year/:kind' => 'data#budget_execution_deviation', as: :data_budget_execution_deviation
        end
      end
    end
  end
end
