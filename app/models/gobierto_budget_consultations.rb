# frozen_string_literal: true

module GobiertoBudgetConsultations
  def self.table_name_prefix
    "gbc_"
  end

  def self.searchable_models
    []
  end

  def self.doc_url
    "https://gobierto.readme.io/docs/consultas-sobre-presupuestos"
  end

  def self.root_path(_)
    Rails.application.routes.url_helpers.gobierto_budget_consultations_consultations_path
  end
end
