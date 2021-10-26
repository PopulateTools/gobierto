# frozen_string_literal: true

namespace :gobierto_budgets do
  namespace :data do
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

      csv_data = CSV.read(csv_path, col_sep: Utils::CsvUtils.detect_separator(csv_path), headers: true, header_converters: [lambda { |header| header.downcase }])
      importer = GobiertoBudgetsData::GobiertoBudgets::InvoicesCsvImporter.new(csv_data, **opts)

      organization_ids = importer.rows.map(&:organization_id).uniq.compact
      sites = Site.where(organization_id: organization_ids)

      nitems = importer.import!
      puts "[SUCCESS] Imported #{nitems}"

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
      Rails.cache.clear
      puts "[SUCCESS] Expired Rails cache"
    end
  end
end
