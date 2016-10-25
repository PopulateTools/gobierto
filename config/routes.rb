Rails.application.routes.draw do
  # The root page is kind of dynamic
  root 'meta_welcome#index'

  if Rails.env.development?
    get '/sandbox' => 'sandbox#index'
    get '/sandbox/*template' => 'sandbox#show'
  end

  localized do
    namespace :gobierto_sites, path: '', module: 'gobierto_sites' do
      constraints GobiertoSiteConstraint.new do
        get 'site' => redirect('/presupuestos/resumen')

        # legal pages (TODO: we should merge them)
        get 'privacy' => 'pages#privacy'
        get 'legal' => 'pages#legal'
        get 'cookie_warning' => 'pages#cookie_warning'

        get 'budgets/summary(/:year)' => 'budgets#index', as: :budgets
        get 'budgets/budget_lines/:year/:area_name/:kind' => 'budget_lines#index', as: :budget_lines
        get 'budgets/budget_lines/:id/:year/:area_name/:kind' => 'budget_lines#show', as: :budget_line
        get 'budget_line_descendants/:year/:area_name/:kind' => 'budget_line_descendants#index', as: :budget_line_descendants
        get 'budgets/execution(/:year)' => 'budgets_execution#index', as: :budgets_execution
        get 'budgets/treemap(/:year)' => 'budget_lines#treemap', as: :budget_lines_treemap
      end
    end
  end

  namespace :gobierto_budgets, path: '/', module: 'gobierto_budgets' do
    resources :featured_budget_lines, only: [:show]

    namespace :api do
      get '/data/lines/:ine_code/:year/:what' => 'data#lines', as: :data_lines
      get '/data/compare/:ine_codes/:year/:what' => 'data#compare', as: :data_compare
      get '/data/lines/budget_line/:ine_code/:year/:what/:kind/:code/:area' => 'data#lines', as: :data_lines_budget_line
      get '/data/compare/budget_line/:ine_codes/:year/:what/:kind/:code/:area' => 'data#compare', as: :data_compare_budget_lines
      get '/data/widget/total_budget/:ine_code/:year' => 'data#total_budget', as: :data_total_budget
      get '/data/widget/total_budget_per_inhabitant/:ine_code/:year' => 'data#total_budget_per_inhabitant', as: :data_total_budget_per_inhabitant
      get '/data/widget/budget/:ine_code/:year/:code/:area/:kind' => 'data#budget', as: :data_budget
      get '/data/widget/budget_execution/:ine_code/:year/:code/:area/:kind' => 'data#budget_execution', as: :data_budget_execution
      get '/data/widget/budget_per_inhabitant/:ine_code/:year/:code/:area/:kind' => 'data#budget_per_inhabitant', as: :data_budget_per_inhabitant
      get '/data/widget/budget_percentage_over_total/:ine_code/:year/:code/:area/:kind' => 'data#budget_percentage_over_total', as: :data_budget_percentage_over_total
      get '/data/widget/population/:ine_code/:year' => 'data#population', as: :data_population
      get '/data/widget/ranking/:year/:kind/:area/:variable(/:code)' => 'data#ranking', as: :data_ranking
      get '/data/widget/total_widget_execution/:ine_code/:year' => 'data#total_budget_execution', as: :data_total_budget_execution
      get '/data/widget/budget_execution_deviation/:ine_code/:year/:kind' => 'data#budget_execution_deviation', as: :data_budget_execution_deviation
      get '/data/widget/debt/:ine_code/:year' => 'data#debt', as: :data_debt

      get '/categories' => 'categories#index'
      get '/categories/:area/:kind' => 'categories#index'
      get '/places' => 'places#index'
      get '/data/:ine_code/:year/:kind/:area' => 'data#budgets'
      get '/data/debt/:year' => 'data#municipalities_debt'
      get '/data/population/:year' => 'data#municipalities_population'

      get '/intelligence/budget_lines/:ine_code/:years' => 'intelligence#budget_lines', as: :intelligence_budget_lines
      get '/intelligence/budget_lines_means/:ine_code/:year' => 'intelligence#budget_lines_means', as: :intelligence_budget_lines_means
    end

    constraints GobiertoBudgetsConstraint.new do
      get 'search' => 'search#index'
      get 'categories/:slug/:year/:area/:kind' => 'search#categories', as: :search_categories
      get 'all_categories/:slug/:year' => 'search#all_categories', as: :search_all_categories

      get '/budget_lines/:slug/:year/:code/:kind/:area' => 'budget_lines#show', as: :budget_line
      get '/budget_lines/:slug/:year/:code/:kind/:area/feedback/:question_id' => 'budget_lines#feedback', as: :budget_line_feedback
      get '/places/:slug' => 'places#show'
      get '/places/:slug/inteligencia' => 'places#intelligence'
      get '/places/:slug/:year/execution' => 'places#execution', as: :place_execution
      get '/places/:slug/:year/debt' => 'places#debt_alive'
      get '/places/:slug/:year' => 'places#show', as: :place
      get '/places/:slug/:year/:kind/:area' => 'places#budget', as: :place_budget
    end
  end
end
