# frozen_string_literal: true

namespace :gobierto_budgets do
  namespace :data do
    desc "Import CSV with extra data"
    task :import_extra_data, [:site_domain, :csv_path] => [:environment] do |_t, args|
      site = Site.find_by(domain: args[:site_domain])

      if site.nil?
        puts "[ERROR] No site found for domain: #{args[:site_domain]}"
        exit -1
      end

      csv_path = args[:csv_path]
      unless File.file?(csv_path)
        puts "[ERROR] No CSV file found: #{csv_path}"
        exit -1
      end

      CSV.read(csv_path, headers: true).each do |row|
        year = row["Fecha"].to_s
        population = row["Habitantes"].to_i
        debt = row["Deuda"].to_f.round(2)

        place_id = site.place.id
        id = [place_id, year].join('/')
        province_id = site.place.province.id.to_i
        autonomous_region_id = site.place.province.autonomous_region.id.to_i

        item = {
          "organization_id" => place_id,
          "ine_code" => place_id,
          "year" => year,
          "value" => debt,
          "province_id" => province_id,
          "autonomy_id" => autonomous_region_id
        }

        debt_data = [
          {
            index: {
              _index: GobiertoBudgetsData::GobiertoBudgets::ES_INDEX_DATA,
              _type: GobiertoBudgetsData::GobiertoBudgets::DEBT_TYPE,
              _id: id,
              data: item
            }
          }
        ]

        GobiertoBudgetsData::GobiertoBudgets::SearchEngineWriting.client.bulk(body: debt_data)
        puts "[SUCCESS] Debt #{debt} for #{year}"

        item = {
          "organization_id" => place_id,
          "ine_code" => place_id,
          "year" => year,
          "value" => population,
          "province_id" => province_id,
          "autonomy_id" => autonomous_region_id
        }

        population_data = [
          {
            index: {
              _index: GobiertoBudgetsData::GobiertoBudgets::ES_INDEX_DATA,
              _type: GobiertoBudgetsData::GobiertoBudgets::POPULATION_TYPE,
              _id: id,
              data: item
            }
          }
        ]
        GobiertoBudgetsData::GobiertoBudgets::SearchEngineWriting.client.bulk(body: population_data)

        puts "[SUCCESS] Population #{population} for #{year}"
      end
    end
  end
end
