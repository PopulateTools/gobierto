# frozen_string_literal: true

module GobiertoBudgets
  def self.table_name_prefix
    'gb_'
  end

  def self.searchable_models
    [ GobiertoBudgets::BudgetLine ]
  end

  def self.doc_url
    "https://gobierto.readme.io/docs/presupuestos"
  end

  def self.root_path(current_site)
    if current_site.gobierto_budgets_settings && current_site.gobierto_budgets_settings.settings["budgets_elaboration"]
      Rails.application.routes.url_helpers.gobierto_budgets_budgets_elaboration_path
    else
      Rails.application.routes.url_helpers.gobierto_budgets_budgets_path(::GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Year.last)
    end
  end

  class << self
    alias_method :cache_base_key, :table_name_prefix
  end
end
