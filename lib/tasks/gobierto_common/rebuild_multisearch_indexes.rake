# frozen_string_literal: true

namespace :common do
  desc "Rebuild multisearch indexes of all searchable models"
  task rebuild_multisearch_indexes: :environment do
    site_modules = Rails.application.config_for(:application).dig("site_modules") << { "namespace" => "GobiertoCms" }

    site_modules.each do |site_module|
      next unless Module.const_defined?(site_module["namespace"])

      module_class = site_module["namespace"].constantize
      next unless module_class.respond_to?(:searchable_models)

      module_class.searchable_models.each do |searchable_model|
        next unless searchable_model.respond_to?(:multisearchable) && searchable_model.respond_to?(:pg_search_multisearchable_options)

        reindex_model(searchable_model)
      end
    end

    reindex_model(GobiertoAttachments::Attachment)
    reindex_model(GobiertoCalendars::Event)
  end

  def reindex_model(searchable_model)
    puts "\n===== Reindexing #{searchable_model}...\n"
    PgSearch::Multisearch.rebuild(searchable_model)
  end
end
