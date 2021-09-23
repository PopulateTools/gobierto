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

    desc "Import CSV. Index valid values: forecast, forecast_updated, execution"
    task :import, [:site_domain, :csv_path, :index, :year] => [:environment] do |_t, args|
      def get_population(site)
        from_year = Date.today.year
        to_year = 2010
        stats = GobiertoBudgets::SiteStats.new site: site, year: from_year
        population = stats.population
        year = from_year
        while population.nil? && year >= to_year
          year -= 1
          population = stats.population(year)
        end
        population
      end

      site = Site.find_by(domain: args[:site_domain])

      if site.nil?
        puts "[ERROR] No site found for domain: #{args[:site_domain]}"
        exit -1
      end

      year = args[:year]
      if year !~ /\A\d+\z/
        puts "[ERROR] Invalid year argument: #{year}"
        exit -1
      end

      csv_path = args[:csv_path]
      unless File.file?(csv_path)
        puts "[ERROR] No CSV file found: #{csv_path}"
        exit -1
      end

      index = case args[:index]
                when "forecast"
                  GobiertoData::GobiertoBudgets::ES_INDEX_FORECAST
                when "forecast_updated"
                  GobiertoData::GobiertoBudgets::ES_INDEX_FORECAST_UPDATED
                when "execution"
                  GobiertoData::GobiertoBudgets::ES_INDEX_EXECUTED
                else
                  puts "[ERROR] Invalid argument index: #{args[:index]}"
                  exit -1
                end

      base_data = {
        organization_id: site.place.id,
        ine_code: site.place.id.to_i,
        province_id: site.place.province.id.to_i,
        autonomous_region_id: site.place.province.autonomous_region.id.to_i,
        year: year,
        population: get_population(site)
      }

      data = []
      CSV.read(csv_path, headers: true).each do |row|
        code = row["Codigo"].to_s
        amount = row["Importe"].to_f.round(2)
        kind = row["Tipo"]
        type = row["Area"] == "E" ? GobiertoData::GobiertoBudgets::ECONOMIC_BUDGET_TYPE : GobiertoData::GobiertoBudgets::FUNCTIONAL_BUDGET_TYPE
        level = code.length
        parent_code = level == 1 ? nil : code[0..-2]

        data.push(base_data.merge({
          amount: amount,
          code: code,
          level: level,
          kind: kind,
          amount_per_inhabitant: (amount / base_data[:population]).round(2),
          parent_code: parent_code,
          type: type
        }).stringify_keys)
      end

      nitems = GobiertoData::GobiertoBudgets::BudgetLinesImporter.new(index: index, year: year.to_i, data: data).import!
      puts "[SUCCESS] Imported #{nitems} in index #{index} for year #{year}"

      action = "budgets_updated"
      Publishers::GobiertoBudgetsActivity.broadcast_event(action, {
        action: action,
        site_id: site.id
      })
    end
  end
end
