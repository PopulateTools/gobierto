# frozen_string_literal: true

namespace :gobierto_budgets do
  namespace :pg_search do
    desc "Rebuild multisearch indexes of Budget lines by domain and year"
    task :reindex, [:site_domain, :year] => [:environment] do |_t, args|
      site = Site.find_by!(domain: args[:site_domain])
      autodetect_year = args[:year].blank?
      year = args[:year].to_i
      organization_id = site.organization_id

      puts "== Reindexing records for site #{site.domain}=="

      # Delete all Budget Line PgSearch documents within this site

      if autodetect_year
        site.pg_search_documents.where(searchable_type: "GobiertoBudgets::BudgetLine").destroy_all
      else
        site.pg_search_documents.where(searchable_type: "GobiertoBudgets::BudgetLine").where("meta @> ?", { year: year }.to_json).destroy_all
      end

      GobiertoCore::CurrentScope.current_site = site

      year = autodetect_year ? GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Year.last_year_with_data : args[:year].to_i

      GobiertoBudgets::BudgetArea.all_areas.each do |area|
        area.available_kinds.each do |kind|
          puts "\n[INFO] area = '#{area.area_name}' kind = '#{kind}'"
          puts "---------------------------------------------------"

          forecast_hits = request_budget_lines_from_elasticsearch(
            GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast,
            area,
            organization_id,
            year
          )

          puts "[INFO] Found #{forecast_hits.size} forecast #{area.area_name} #{kind} BudgetLine records"

          forecast_budget_lines = forecast_hits.map do |h|
            create_budget_line(site, "index_forecast", h)
          end

          GobiertoBudgets::BudgetLine.pg_search_reindex_collection(forecast_budget_lines)
        end
      end
    end

    def create_budget_line(site, index, elasticsearch_hit)
      GobiertoBudgets::BudgetLine.new(
        site: site,
        index: index,
        area_name: elasticsearch_hit["_type"],
        kind: elasticsearch_hit["_source"]["kind"],
        code: elasticsearch_hit["_source"]["code"],
        year: elasticsearch_hit["_source"]["year"],
        amount: elasticsearch_hit["_source"]["amount"]
      )
    end

    def request_budget_lines_from_elasticsearch(index, area, organization_id, year)
      query = {
        query: {
          filtered: {
            filter: {
              bool: {
                must: [
                  { term: { organization_id: organization_id } },
                  { term: { year: year } }
                ]
              }
            }
          }
        },
        size: 10_000
      }

      GobiertoBudgets::SearchEngine.client.search(
        index: index,
        type: area.area_name,
        body: query
      )["hits"]["hits"]
    end
  end
end
