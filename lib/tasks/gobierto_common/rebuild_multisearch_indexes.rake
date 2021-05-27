# frozen_string_literal: true

namespace :common do
  desc "Rebuild multisearch indexes of all searchable models. Set force_reset as true to delete existing indexes"
  task :rebuild_multisearch_indexes, [:force_reset] => [:environment] do |_t, args|
    force_reset = args[:force_reset] == "true"

    site_modules = Rails.application.config_for(:application).dig(:site_modules) << { namespace: "GobiertoCms" }

    site_modules.each do |site_module|
      next unless Module.const_defined?(site_module[:namespace])

      module_class = site_module[:namespace].constantize
      next unless module_class.respond_to?(:searchable_models)

      module_class.searchable_models.each do |searchable_model|
        next unless searchable_model.respond_to?(:multisearchable) && searchable_model.respond_to?(:pg_search_multisearchable_options)

        reindex_model(searchable_model, force_reset)
      end
    end

    reindex_model(GobiertoAttachments::Attachment, force_reset)
    reindex_model(GobiertoCalendars::Event, force_reset)
    reindex_model(GobiertoData::Dataset, force_reset)
  end

  def reindex_model(searchable_model, force_reset)
    if force_reset || PgSearch::Document.where(searchable_type: searchable_model.name).empty?
      puts "\n===== Reindexing #{searchable_model}...\n"
      PgSearch::Multisearch.rebuild(searchable_model)
    else
      puts "\n===== Skipping #{searchable_model}...\n      There are search documents created for this model. Remove them or run the task with force_reset option.\n"
    end
  end
end
