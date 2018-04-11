# frozen_string_literal: true

Rails.application.routes.draw do
  # The root page is kind of dynamic
  constraints GobiertoSiteConstraint.new do
    root "meta_welcome#index"
  end

  unless Rails.env.production?
    get "/sandbox" => "sandbox#index"
    get "/sandbox/*template" => "sandbox#show"
  end

  # Admin module
  namespace :gobierto_admin, as: :admin, path: :admin do
    get "/" => "welcome#index", as: :root

    resource :sessions, only: [:new, :create, :destroy]
    resources :sites, only: [:index, :new, :create, :edit, :update, :destroy]
    namespace :gobierto_core do
      resources :templates, only: [:index] do
        get :edit
      end
      resources :site_templates, only: [:create, :update, :destroy]
    end
    resources :issues do
      collection do
        resource :issue_sort, only: [:create], controller: "issues_sort", path: :issues_sort
      end
    end
    resources :scopes do
      collection do
        resource :scope_sort, only: [:create], controller: "scopes_sort", path: :scopes_sort
      end
    end

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

    namespace :gobierto_budgets do
      resources :options, only: [:index] do
        collection do
          put :update
          put :update_annual_data
        end
      end
      resources :feedback, only: [:index]
    end

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
        resources :person_statements, only: [:index, :new, :create, :edit, :update], controller: "people/person_statements", as: :statements, path: :statements
        resources :person_posts, only: [:index, :new, :create, :edit, :update], controller: "people/person_posts", as: :posts, path: :blog
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

    namespace :gobierto_participation, as: :participation, path: :participation do
      get "/" => "welcome#index"

      resources :processes, only: [:index, :new, :edit, :create, :update, :destroy] do
        put :recover
        post :update_current_stage
        resources :process_stages, only: [:create, :destroy, :edit, :index, :new, :update], controller: "processes/process_stages", as: :process_stages, path: :process_stages do
          resources :pages, only: [:new, :create, :edit, :update], controller: "processes/process_stage_pages", as: :process_stage_page, path: :process_stage_page
          collection do
            resource :process_stage_sort, only: [:create], controller: "processes/process_stages_sort", path: :process_stages_sort
          end
        end
        resources :file_attachments, only: [:index], controller: "processes/process_file_attachments", as: :file_attachments, path: :file_attachments
        resources :events, only: [:index], controller: "processes/process_events", as: :events, path: :events
        resources :pages, only: [:index], controller: "processes/process_pages", as: :pages, path: :pages
        resources :polls, only: [:index, :new, :edit, :create, :update, :destroy], controller: "processes/polls" do
          resources :answers, only: [:index], controller: "processes/poll_answers"
          put :recover
        end
        resources :contribution_containers, only: [:new, :edit, :create, :update, :index, :show, :destroy], controller: "processes/process_contribution_containers", as: :contribution_containers, path: :contribution_containers do
          put :recover
        end
      end
    end

    namespace :gobierto_common, as: :common, path: nil do
      resources :collections, only: [:show, :new, :create, :edit, :update]
      resources :content_blocks, only: [:new, :create, :edit, :update, :destroy]
    end

    namespace :gobierto_plans, as: :plans, path: :plans do
      resources :plans, except: [:show], path: "" do
        get :data
        put :recover
      end
      resources :plan_types, except: [:show], path: :plan_types do
        put :recover
      end
    end

    namespace :gobierto_cms, as: :cms, path: :cms do
      resources :pages, only: [:index, :new, :edit, :create, :update, :destroy] do
        put :recover
      end
      resources :sections, only: [:index, :new, :edit, :create, :update, :show] do
        resources :section_items, only: [:index, :create, :destroy, :update, :show]
        get :pages
      end
    end

    namespace :gobierto_attachments, as: :attachments, path: :attachments do
      resources :file_attachments, only: [:index, :create, :new, :edit, :update, :destroy] do
        put :recover
      end
      namespace :api do
        resources :attachments, only: [:index, :show, :create, :update, :destroy]
        post "/attachings" => "attachings#create"
        delete "/attachings" => "attachings#destroy"
      end
    end

    namespace :gobierto_calendars, as: :calendars do
      resources :events do
        put :recover
      end
      resources :collections, only: [:index]
      resources :calendar_configurations, only: [:edit, :update], controller: "calendar_configuration", as: :configurations, path: :configurations do
        member do
          put 'sync_calendars'
        end
      end
    end
  end

  # User module
  namespace :user do
    constraints GobiertoSiteConstraint.new do
      get "/" => "welcome#index", as: :root

      resource :sessions, only: [:new, :create, :destroy]
      resource :custom_session, only: [:new, :create, :destroy] do
        collection do
          post :auth_callback
        end
      end
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
  namespace :gobierto_budget_consultations, path: "consultas-presupuestos" do
    constraints GobiertoSiteConstraint.new do
      resources :consultations, only: [:index, :show], path: "" do
        get "partidas", to: "consultations/consultation_items#index", as: :item_summary
        get "participa", to: "consultations/consultation_responses#new", as: :new_response
        post "participa", to: "consultations/consultation_responses#create", as: :response, via: [:post]
        get "terminado", to: "consultations/consultation_confirmations#show", as: :show_confirmation
      end

      resources :consultation_participations, only: [:show], path: "participaciones"
    end
  end

  # Gobierto People module
  namespace :gobierto_people, path: "/" do
    constraints GobiertoSiteConstraint.new do
      get "cargos-y-agendas" => "welcome#index", as: :root

      # Agendas
      resources :person_events, only: [:index], as: :events, path: "agendas"
      resources :government_party_person_events, only: [:index], as: :government_party_events, path: "agendas/gobierno"
      resources :opposition_party_person_events, only: [:index], as: :opposition_party_events, path: "agendas/oposicion"
      resources :executive_category_person_events, only: [:index], as: :executive_category_events, path: "agendas/directivos"

      resources :past_person_events, only: [:index], as: :past_events, path: "agendas/eventos-pasados"
      resources :government_party_past_person_events, only: [:index], as: :government_party_past_events, path: "agendas/gobierno/eventos-pasados"
      resources :opposition_party_past_person_events, only: [:index], as: :opposition_party_past_events, path: "agendas/oposicion/eventos-pasados"
      resources :executive_category_past_person_events, only: [:index], as: :executive_category_past_events, path: "agendas/directivos/eventos-pasados"

      resources :people_past_person_events, only: [:index], controller: "people/past_person_events", as: :person_past_events, path: "agendas/:container_slug/eventos-pasados"
      resources :people_person_events, only: [:index, :show], controller: "people/person_events", as: :person_events, path: "agendas/:container_slug", param: :slug

      # Blogs
      resources :person_posts, only: [:index], as: :posts, path: "blogs/posts"
      resources :person_post_tags, only: [:show], as: :post_tags, path: "blogs/tags"

      resources :people_person_post_tags, only: [:show], controller: "people/person_post_tags", as: :person_post_tags, path: "blogs/:person_slug/tags"
      resources :people_person_posts, only: [:index, :show], controller: "people/person_posts", as: :person_posts, path: "blogs/:person_slug", param: :slug

      # Statements
      resources :person_statements, only: [:index], as: :statements, path: "declaraciones"
      resources :person_gifts, only: [:index], as: :gifts, path: "obsequios-y-regalos"
      resources :person_travels, only: [:index], as: :travels, path: "viajes-y-desplazamientos"
      resources :people_person_statements, only: [:index, :show], controller: "people/person_statements", as: :person_statements, path: "declaraciones/:person_slug", param: :slug

      # Officials
      resources :people, only: [:index], path: "personas"
      resources :government_party_people, only: [:index], path: "personas/gobierno"
      resources :opposition_party_people, only: [:index], path: "personas/oposicion"
      resources :executive_category_people, only: [:index], path: "personas/directivos"

      # Political Groups
      resources :political_group, only: [:show], path: "personas/grupos-politicos", param: :slug do
        resources :people, only: [:index], controller: "political_groups/people", path: "/"
      end

      # People
      resources :people, only: [:show], path: "personas", param: :slug do
        resource :person_bio, only: [:show], controller: "people/person_bio", as: :bio, path: "biografia"
        resources :person_messages, only: [:create], controller: "people/person_messages", as: :messages, path: "contacto", param: :slug do
          collection do
            get "/" => "people/person_messages#new", as: :new
          end
        end
        resource :google_calendar_calendars, only: [:edit, :update], controller: "people/google_calendar/calendars", as: :google_calendar_calendars
      end
    end

    # Google calendar integration hook
    resource :google_calendar_authorization, only: [:new], controller: "people/google_calendar/authorization", as: :google_calendar_authorization
  end

  # Gobierto Budgets module
  namespace :gobierto_budgets, path: "presupuestos" do
    constraints GobiertoSiteConstraint.new do
      root "sites#show"

      resources :featured_budget_lines, only: [:show]

      get "resumen(/:year)" => "budgets#index", as: :budgets
      get "partidas/:year/:area_name/:kind" => "budget_lines#index", as: :budget_lines
      get "partidas/:id/:year/:area_name/:kind" => "budget_lines#show", as: :budget_line
      get "budget_line_descendants/:year/:area_name/:kind" => "budget_line_descendants#index", as: :budget_line_descendants
      get "ejecucion(/:year)" => "budgets_execution#index", as: :budgets_execution
      get "guia" => "budgets#guide", as: :budgets_guide
      get "elaboracion" => "budgets_elaboration#index", as: :budgets_elaboration
      get "budgets/treemap(/:year)" => "budget_lines#treemap", as: :budget_lines_treemap

      get "all_categories/:year" => "search#all_categories", as: :search_all_categories

      get "feedback/step1" => "feedback#step1", as: :feedback_step1
      get "feedback/step2" => "feedback#step2", as: :feedback_step2
      get "feedback/step3" => "feedback#step3", as: :feedback_step3
      post "feedback/follow" => "feedback#follow", as: :feedback_follow
      get "feedback/load_ask_more_information" => "feedback#load_ask_more_information", as: :feedback_load_ask_more_information
      get "recibo" => "receipts#show", as: :receipt
      get "proveedores-facturas" => "providers#index", as: :providers
      get "indicadores(/:year)" => "indicators#index", as: :indicators

      namespace :api do
        get "/categories" => "categories#index"
        get "/categories/:area/:kind" => "categories#index"
        get "/data/widget/budget/:organization_id/:year/:code/:area/:kind" => "data#budget", as: :data_budget
        get "/data/widget/budget_per_inhabitant/:organization_id/:year/:code/:area/:kind" => "data#budget_per_inhabitant", as: :data_budget_per_inhabitant
        get "/data/lines/:organization_id/:year/:what" => "data#lines", as: :data_lines
        get "/data/lines/budget_line/:organization_id/:year/:what/:kind/:code/:area" => "data#lines", as: :data_lines_budget_line
        get "/data/widget/budget_execution_deviation/:organization_id/:year/:kind" => "data#budget_execution_deviation", as: :data_budget_execution_deviation
        get "/data/widget/budget_execution_comparison/:organization_id/:year/:kind/:area" => "data#budget_execution_comparison", as: :data_budget_execution_comparison
      end
    end
  end

  # Gobierto Observatory module
  namespace :gobierto_observatory, path: "observatorio" do
    constraints GobiertoSiteConstraint.new do
      root "observatory#index"
    end
  end

  # Gobierto Plans module
  namespace :gobierto_plans, path: "planes" do
    constraints GobiertoSiteConstraint.new do
      get "/" => "plan_types#index", as: :root
      get ":slug(/:year)" => "plan_types#show", as: :plan
    end
  end

  # Gobierto Indicators module
  namespace :gobierto_indicators, path: "indicadores" do
    constraints GobiertoSiteConstraint.new do
      root "indicators#index"
      get "ita(/:year)" => "indicators#ita", as: :indicators_ita
      get "ip(/:year)" => "indicators#ip", as: :indicators_ip
      get "gci(/:year)" => "indicators#gci", as: :indicators_gci
    end
  end

  # Gobierto CMS module
  namespace :gobierto_cms, path: "" do
    constraints GobiertoSiteConstraint.new do
      get "/s/:slug_section/:id" => "pages#show",    as: :section_item
      get "/s/:slug_section"     => "sections#show", as: :section
      get "/paginas/:id"         => "pages#index",   as: :pages
      get "/pagina/:id"          => "pages#show",    as: :page
      get "/noticias/:id"        => "news#index",    as: :news_index
      get "/noticia/:id"         => "news#show",     as: :news
    end
  end

  # Gobierto Participation module
  namespace :gobierto_participation, path: "participacion" do
    constraints GobiertoSiteConstraint.new do
      get "/" => "welcome#index", as: :root

      resources :processes, only: [:index, :show], path: "p" do
        resources :contribution_containers, only: [:index, :show], controller: "processes/contribution_containers", path: "aportaciones" do
          resources :contributions, only: [:new, :create, :show], controller: "processes/contributions", path: :contributions do
            resource :vote, only: [:create, :destroy]
            resource :flag, only: [:create, :destroy]
            resource :comment, only: [:create, :index]
          end
        end

        resources :polls, only: [:index], controller: "processes/polls", path: "encuestas" do
          resources :answers, only: [:new, :create], controller: "processes/poll_answers"
        end
        resources :attachments, only: [:index], controller: "processes/attachments", path: "documentos"
        resources :past_process_events, only: [:index], controller: "processes/past_process_events", as: :past_process_events, path: "agendas/eventos-pasados"
        resources :events, only: [:index, :show], controller: "processes/events", path: "agendas"
        resources :news, only: [:index], controller: "processes/news", path: "noticias"
        resources :activities, only: [:index], controller: "processes/activities", path: "actividad"
      end

      resources :issues, only: [:index, :show], path: "temas" do
        resources :attachments, only: [:index], controller: "issues/attachments", path: "documentos"
        resources :events, only: [:index, :show], controller: "issues/events", path: "agendas"
        resources :activities, only: [:index], controller: "issues/activities", path: "actividad"
      end

      resources :scopes, only: [:index, :show], path: "ambitos" do
        resources :attachments, only: [:index], controller: "scopes/attachments", path: "documentos"
        resources :events, only: [:index, :show], controller: "scopes/events", path: "agendas"
        resources :activities, only: [:index], controller: "scopes/activities", path: "actividad"
      end

      resources :attachments, only: [:index], controller: "attachments", path: "documentos"
      resources :past_participation_events, only: [:index], controller: "past_participation_events", as: :past_participation_events, path: "agendas/eventos-pasados"
      resources :events, only: [:index, :show], controller: "events", path: "agendas"
      resources :news, only: [:index], controller: "news", path: "noticias"
      resources :activities, only: [:index], controller: "activities", path: "actividad"
    end
  end

  # Gobierto Exports module
  namespace :gobierto_exports, path: "datos" do
    constraints GobiertoSiteConstraint.new do
      root "exports#index"
    end
  end

  # Gobierto Attachments module
  namespace :gobierto_attachments, path: 'docs' do
    constraints GobiertoSiteConstraint.new do
      resources :attachments, only: [:show], path: ''
    end
  end

  namespace :gobierto_attachments, path: "" do
    constraints GobiertoSiteConstraint.new do
      get "/documento/:id" => 'attachment_documents#show', as: :document
    end
  end
end
