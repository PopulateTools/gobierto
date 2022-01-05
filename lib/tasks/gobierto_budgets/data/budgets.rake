# frozen_string_literal: true

require "#{Rails.root}/lib/utils/csv_utils"

namespace :gobierto_budgets do
  namespace :data do
    # Calculate total amounts
    TOTAL_BUDGET_INDEXES = [
      GobiertoBudgetsData::GobiertoBudgets::ES_INDEX_FORECAST,
      GobiertoBudgetsData::GobiertoBudgets::ES_INDEX_EXECUTED,
      GobiertoBudgetsData::GobiertoBudgets::ES_INDEX_FORECAST_UPDATED
    ].freeze

    def after_import_tasks(organization_ids, sites)
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
      sites.each do |site|
        cache_service = GobiertoCommon::CacheService.new(site, "GobiertoBudgets")
        cache_service.clear
      end
      puts "[SUCCESS] Expired Rails cache for GobiertoBudgets module"
    end

    desc "Import budgets from CSV with gobierto_budgets_data format"
    task :import_gobierto_budgets_data, [:csv_path] => :environment do |_t, args|
      require "gobierto_budgets/category"

      # Import budgets
      csv_path = args[:csv_path]
      unless File.file?(csv_path)
        puts "[ERROR] No CSV file found: #{csv_path}"
        exit(-1)
      end

      csv_data = CSV.read(csv_path, col_sep: CsvUtils.detect_separator(csv_path), headers: true, header_converters: [lambda { |header| header.downcase }])
      importer = GobiertoBudgetsData::GobiertoBudgets::BudgetLinesCsvImporter.new(csv_data)

      organization_ids = importer.csv.map { |row| row.field("organization_id") }.uniq

      if organization_ids.empty?
        puts "[ERROR] No organization_ids provided"
        exit(-1)
      end

      sites = Site.where(organization_id: organization_ids)
      nitems = importer.import!
      puts "[SUCCESS] Imported #{nitems} rows for sites #{sites.pluck(:domain).to_sentence}"

      after_import_tasks(organization_ids, sites)
    end

    desc "Import budgets from CSV with SICALWIN format. Expects three arguments: csv_path, INE code and year"
    task :import_gobierto_budgets_sicalwin, [:csv_path,:organization_id,:year] => :environment do |_t, args|
      require "gobierto_budgets/category"

      # Import budgets
      csv_path = args[:csv_path]
      unless File.file?(csv_path)
        puts "[ERROR] No CSV file found: #{csv_path}"
        exit(-1)
      end

      year = args[:year]
      if year.blank? || year.to_i < 2000 || year.to_i > 2100
        puts "[ERROR] Wrong year argument provided"
        exit(-1)
      end

      organization_id = args[:organization_id]
      if organization_id.blank? || organization_id !~ /\A[0-9]+\z/
        puts "[ERROR] Wrong organization_id argument provided"
        exit(-1)
      end

      csv_data = CSV.read(csv_path, col_sep: CsvUtils.detect_separator(csv_path), headers: true)
      importer = GobiertoBudgetsData::GobiertoBudgets::BudgetLinesSicalwinImporter.new(csv_data, year, organization_id)

      organization_ids = [organization_id]
      sites = Site.where(organization_id: organization_ids)
      nitems = importer.import!

      puts "[SUCCESS] Imported #{nitems} rows for sites #{sites.pluck(:domain).to_sentence}"

      after_import_tasks(organization_ids, sites)
    end
  end
end
