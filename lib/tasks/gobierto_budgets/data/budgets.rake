# frozen_string_literal: true

namespace :gobierto_budgets do
  namespace :data do
    desc "Import budgets from CSV with gobierto_budgets_data format"
    task :import_gobierto_budgets_data, [:csv_path] => :environment do |_t, args|

      csv_path = args[:csv_path]
      unless File.file?(csv_path)
        puts "[ERROR] No CSV file found: #{csv_path}"
        exit(-1)
      end

      importer = GobiertoData::GobiertoBudgets::BudgetLinesCsvImporter.new(CSV.read(csv_path, headers: true))

      organization_ids = importer.csv.map { |row| row.field("organization_id") }.uniq
      sites = Site.where(organization_id: organization_ids)

      nitems = importer.import!
      puts "[SUCCESS] Imported #{nitems}"

      action = "budgets_updated"
      sites.each do |site|
        Publishers::GobiertoBudgetsActivity.broadcast_event(action, {
          action: action,
          site_id: site.id
        })
      end

        end
      end

    end
  end
end
