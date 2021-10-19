# frozen_string_literal: true

namespace :gobierto_budgets do
  namespace :data do
    desc "Import budgets from CSV with gobierto_budgets_data format"
    task :import_gobierto_budgets_data, [:csv_path] => :environment do |_t, args|

      # Import budgets
      csv_path = args[:csv_path]
      unless File.file?(csv_path)
        puts "[ERROR] No CSV file found: #{csv_path}"
        exit(-1)
      end

      csv_data = CSV.read(csv_path, headers: true, header_converters: [lambda { |header| header.downcase }])
      importer = GobiertoBudgetsData::GobiertoBudgets::BudgetLinesCsvImporter.new(csv_data)

      organization_ids = importer.csv.map { |row| row.field("organization_id") }.uniq
      sites = Site.where(organization_id: organization_ids)

      nitems = importer.import!
      puts "[SUCCESS] Imported #{nitems}"

      # Calculate total amounts
      TOTAL_BUDGET_INDEXES = [
        GobiertoBudgetsData::GobiertoBudgets::ES_INDEX_FORECAST,
        GobiertoBudgetsData::GobiertoBudgets::ES_INDEX_EXECUTED,
        GobiertoBudgetsData::GobiertoBudgets::ES_INDEX_FORECAST_UPDATED
      ].freeze

      if organization_ids.any?
        organization_ids.each do |organization_id|
          GobiertoBudgets::SearchEngineConfiguration::Year.all.each do |year|
            TOTAL_BUDGET_INDEXES.each do |index|
              puts " - Calculating totals for #{organization_id} in year #{year} for index #{index}"

              total_budget_calculator = GobiertoBudgetsData::GobiertoBudgets::TotalBudgetCalculator.new(
                organization_id: organization_id,
                year: year,
                index: index
              )
              total_budget_calculator.calculate!
            end
          end
          puts "[SUCCESS] Calculated total budgets for organization #{organization_id}"
        end
      end

      # Publish updated activity
      action = "budgets_updated"
      sites.each do |site|
        Publishers::GobiertoBudgetsActivity.broadcast_event(action, {
          action: action,
          site_id: site.id
        })
      end
      puts "[SUCCESS] Published activity budgets_updated"

      # Recalculate bubbles
      if organization_ids.any?
        organization_ids.each do |organization_id|
          GobiertoBudgetsData::GobiertoBudgets::Bubbles.dump(organization_id)
          puts "[SUCCESS] Calculated bubbles for organization #{organization_id}"
        end
      end

      # Expire Rails cache
      Rails.cache.clear
      puts "[SUCCESS] Expired Rails cache"
    end
  end
end
