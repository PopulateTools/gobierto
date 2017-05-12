Rails.application.routes.draw do
  # The root page is kind of dynamic
  constraints GobiertoSiteConstraint.new do
    root 'meta_welcome#index'
  end

  if Rails.env.development?
    get '/sandbox' => 'sandbox#index'
    get '/sandbox/*template' => 'sandbox#show'
  end

  # Admin module
  namespace :gobierto_admin, as: :admin, path: :admin do
    get '/' => 'welcome#index', as: :root

    resource :sessions, only: [:new, :create, :destroy]
    resources :sites, only: [:index, :new, :create, :edit, :update, :destroy]

    namespace :sites do
      resource :sessions, only: [:create, :destroy]
    end

    resources :admins, only: [:index, :show, :new, :create, :edit, :update]

    namespace :admin do
      resource :invitations, only: [:new, :create]
      resource :invitation_acceptances, only: [:show]
      resource :passwords, only: [:new, :create, :edit, :update]
      resource :settings, only: [:edit, :update]
    end

    resources :users, only: [:index, :show, :edit, :update] do
      resource :welcome_messages, only: [:create], controller: "users/welcome_messages"
      resource :passwords, only: [:new, :create], controller: "users/passwords"
    end

    namespace :census do
      resource :imports, only: [:new, :create]
    end

    resources :activities, only: [:index]

    namespace :gobierto_budget_consultations, as: :budget, path: :budgets do
      resources :consultations, only: [:index, :show, :new, :create, :edit, :update] do
        resources :consultation_items, controller: "consultations/consultation_items", path: :items
        resource :consultation_items_sort, only: [:create], controller: "consultations/consultation_items_sort", path: :items_sort
        resources :consultation_responses, only: [:index, :show, :new, :create, :destroy], controller: "consultations/consultation_responses", path: :responses
        resource :consultation_reports, only: [:show], controller: "consultations/consultation_reports", path: :report
      end
    end

    namespace :gobierto_people, as: :people, path: :people do
      resources :people, only: [:index, :new, :create, :edit, :update] do
        collection do
          resource :people_sort, only: [:create], controller: "people/people_sort", path: :people_sort
        end
        resources :person_events, only: [:index, :new, :create, :edit, :update], controller: "people/person_events", as: :events, path: :events
        resources :published_person_events, only: [:index], controller: "people/published_person_events", as: :published_events, path: "events/published"
        resources :pending_person_events, only: [:index], controller: "people/pending_person_events", as: :pending_events, path: "events/pending"
        resources :past_person_events, only: [:index], controller: "people/past_person_events", as: :past_events, path: "events/past"
        resources :person_statements, only: [:index, :new, :create, :edit, :update], controller: "people/person_statements", as: :statements, path: :statements
        resources :person_posts, only: [:index, :new, :create, :edit, :update], controller: "people/person_posts", as: :posts, path: :blog
        resource :person_calendar_configuration, only: [:edit, :update], controller: "people/person_calendar_configuration", as: :calendar_configuration, path: :calendar_configuration
      end

      namespace :configuration do
        resource :settings, only: [:edit, :update], path: :settings
        resources :political_groups, only: [:index, :new, :create, :edit, :update], path: :groups do
          collection do
            resource :political_groups_sort, only: [:create], controller: "political_groups_sort", path: :political_groups_sort
          end
        end
      end

      resource :file_attachments, only: [:create]
    end

    namespace :gobierto_common, as: :common, path: nil do
      resources :content_blocks, only: [:new, :create, :edit, :update, :destroy]
    end

    namespace :gobierto_cms, as: :cms, path: :cms do
      resources :pages
      resource :file_attachments, only: [:create]
    end
  end

  # User module
  namespace :user do
    constraints GobiertoSiteConstraint.new do
      get '/' => 'welcome#index', as: :root

      resource :sessions, only: [:new, :create, :destroy]
      resource :registrations, only: [:create]
      resource :confirmations, only: [:new, :create]
      resource :passwords, only: [:create, :edit, :update]
      resource :census_verifications, only: [:new, :create], path: :verifications
      resource :settings, only: [:show, :update]
      resource :subscription_preferences, only: [:update]

      resources :subscriptions, only: [:index, :create, :destroy]
      resources :notifications, only: [:index]
    end
  end

  # Gobierto Budget Consultations module
  namespace :gobierto_budget_consultations, path: 'consultas-presupuestos' do
    constraints GobiertoSiteConstraint.new do
      resources :consultations, only: [:index, :show], path: '' do
        get 'partidas', to: 'consultations/consultation_items#index', as: :item_summary
        get 'participa', to: 'consultations/consultation_responses#new', as: :new_response
        post 'participa', to: 'consultations/consultation_responses#create', as: :response, via: [:post]
        get 'terminado', to: 'consultations/consultation_confirmations#show', as: :show_confirmation
      end

      resources :consultation_participations, only: [:show], path: 'participaciones'
    end
  end

  # Gobierto People module
  namespace :gobierto_people, path: 'cargos-y-agendas' do
    constraints GobiertoSiteConstraint.new do
      get '/' => 'welcome#index', as: :root

      # Agendas

      resources :person_events, only: [:index], as: :events, path: 'agendas'
      resources :government_party_person_events, only: [:index], as: :government_party_events, path: 'agendas/gobierno'
      resources :opposition_party_person_events, only: [:index], as: :opposition_party_events, path: 'agendas/oposicion'
      resources :executive_category_person_events, only: [:index], as: :executive_category_events, path: 'agendas/directivos'

      resources :past_person_events, only: [:index], as: :past_events, path: 'agendas/eventos-pasados'
      resources :government_party_past_person_events, only: [:index], as: :government_party_past_events, path: 'agendas/gobierno/eventos-pasados'
      resources :opposition_party_past_person_events, only: [:index], as: :opposition_party_past_events, path: 'agendas/oposicion/eventos-pasados'
      resources :executive_category_past_person_events, only: [:index], as: :executive_category_past_events, path: 'agendas/directivos/eventos-pasados'

      resources :people_past_person_events, only: [:index], controller: "people/past_person_events", as: :person_past_events, path: 'agendas/:person_slug/eventos-pasados'
      resources :people_person_events, only: [:index, :show], controller: "people/person_events", as: :person_events, path: 'agendas/:person_slug', param: :slug

      # Blogs

      resources :person_posts, only: [:index], as: :posts, path: 'blogs/posts'
      resources :person_post_tags, only: [:show], as: :post_tags, path: 'blogs/tags'

      resources :people_person_post_tags, only: [:show], controller: "people/person_post_tags", as: :person_post_tags, path: 'blogs/:person_slug/tags'
      resources :people_person_posts, only: [:index, :show], controller: "people/person_posts", as: :person_posts, path: 'blogs/:person_slug', param: :slug

      # Statements

      resources :person_statements, only: [:index], as: :statements, path: 'declaraciones'
      resources :person_gifts, only: [:index], as: :gifts, path: 'obsequios-y-regalos'
      resources :person_travels, only: [:index], as: :travels, path: 'viajes-y-desplazamientos'

      resources :people_person_statements, only: [:index, :show], controller: "people/person_statements", as: :person_statements, path: 'declaraciones/:person_slug', param: :slug

      # Officials

      resources :people, only: [:show], path: 'personas', param: :slug do
        resource :person_bio, only: [:show], controller: "people/person_bio", as: :bio, path: 'biografia'
        resources :person_messages, only: [:create], controller: "people/person_messages", as: :messages, path: 'contacto', param: :slug do
          collection do
            get 'nuevo' => 'people/person_messages#new', as: :new
          end
        end
      end

      # Political Groups

      resources :people, only: [:index], path: 'todos-los-cargos'
      resources :government_party_people, only: [:index], path: 'gobierno'
      resources :opposition_party_people, only: [:index], path: 'oposicion'
      resources :executive_category_people, only: [:index], path: 'directivos'

      resources :political_groups, only: [:show], path: 'grupos-politicos' do
        resources :people, only: [:index], controller: "political_groups/people", path: 'cargos'
      end
    end
  end

  # Gobierto Budgets module
  namespace :gobierto_budgets, path: nil do
    constraints GobiertoSiteConstraint.new do
      get 'site' => 'sites#show'

      resources :featured_budget_lines, only: [:show]

      get 'presupuestos/resumen(/:year)' => 'budgets#index', as: :budgets
      get 'presupuestos/partidas/:year/:area_name/:kind' => 'budget_lines#index', as: :budget_lines
      get 'presupuestos/partidas/:id/:year/:area_name/:kind' => 'budget_lines#show', as: :budget_line
      get 'budget_line_descendants/:year/:area_name/:kind' => 'budget_line_descendants#index', as: :budget_line_descendants
      get 'presupuestos/ejecucion(/:year)' => 'budgets_execution#index', as: :budgets_execution
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

  # Gobierto Indicators module
  namespace :gobierto_indicators, path: 'indicadores' do
    constraints GobiertoSiteConstraint.new do
      root 'indicators#index'
    end
  end

  # Gobierto CMS module
  namespace :gobierto_cms, path: 'paginas' do
    constraints GobiertoSiteConstraint.new do
      get ':id' => 'pages#show', as: :page
    end
  end

  # Gobierto Exports module
  namespace :gobierto_exports, path: 'datos' do
    constraints GobiertoSiteConstraint.new do
      root 'exports#index'
    end
  end
end
