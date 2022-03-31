# frozen_string_literal: true

require "#{Rails.root}/lib/utils/csv_utils"

namespace :gobierto_budgets do
  namespace :data do
    def after_invoices_import_tasks(sites)
      # Publish updated activity
      action = "providers_updated"
      sites.each do |site|
        Publishers::GobiertoBudgetsActivity.broadcast_event(action, {
          action: action,
          site_id: site.id
        })
      end
      puts "[SUCCESS] Published activity providers_updated"

      # Expire Rails cache
      sites.each do |site|
        cache_service = GobiertoCommon::CacheService.new(site, "GobiertoBudgets")
        cache_service.clear
      end
      puts "[SUCCESS] Expired Rails cache for GobiertoBudgets module"
    end

    desc "Import invoices from CSV with gobierto_budgets_data format"
    task :import_gobierto_invoices_data, [:csv_path, :organization_id] => :environment do |_t, args|
      # Import invoices
      csv_path = args[:csv_path]
      unless File.file?(csv_path)
        puts "[ERROR] No CSV file found: #{csv_path}"
        exit(-1)
      end

      organization_id = args[:organization_id]
      opts = organization_id.present? ? { organization_id: organization_id } : {}

      csv_data = CSV.read(csv_path, col_sep: CsvUtils.detect_separator(csv_path), headers: true, header_converters: [lambda { |header| header.downcase }])
      importer = GobiertoBudgetsData::GobiertoBudgets::InvoicesCsvImporter.new(csv_data, **opts)

      organization_ids = importer.rows.map(&:organization_id).uniq.compact
      sites = Site.where(organization_id: organization_ids)

      nitems = importer.import!
      puts "[SUCCESS] Imported #{nitems}"

      sites = Site.where(organization_id: organization_id)
      after_invoices_import_tasks(sites)
    end

    desc "Clear previous invoices data"
    task :clear_previous_invoices_data, [:organization_id] => :environment do |_t, args|
      index = GobiertoBudgetsData::GobiertoBudgets::ES_INDEX_INVOICES
      type =  GobiertoBudgetsData::GobiertoBudgets::INVOICE_TYPE
      organization_id = args[:organization_id]

      puts "[START] clear-previous-providers/run.rb organization_id=#{organization_id}"

      terms = [
        {term: { location_id: organization_id }}
      ]

      query = {
        query: {
          filtered: {
            filter: {
              bool: {
                must: terms
              }
            }
          }
        },
        size: 10_000
      }

      count = 0
      response = GobiertoBudgetsData::GobiertoBudgets::SearchEngine.client.search index: index, type: type, body: query
      while response['hits']['total'] > 0
        delete_request_body = response['hits']['hits'].map do |h|
          count += 1
          { delete: h.slice("_index", "_type", "_id") }
        end
        GobiertoBudgetsData::GobiertoBudgets::SearchEngineWriting.client.bulk index: index, type: type, body: delete_request_body
        response = GobiertoBudgetsData::GobiertoBudgets::SearchEngine.client.search index: index, type: type, body: query
      end

      puts "[END] clear-previous-providers/run.rb. Deleted #{count} items"
    end
  end
end
