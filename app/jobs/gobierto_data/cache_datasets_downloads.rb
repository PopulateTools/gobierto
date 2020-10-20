# frozen_string_literal: true

module GobiertoData
  class CacheDatasetsDownloads < ActiveJob::Base
    queue_as :cached_data

    def perform(dataset)
      GobiertoData::Cache.dataset_cache(dataset, format: 'json', update: true) do
        GobiertoData::Connection.execute_query(dataset.site, dataset.rails_model.all.to_sql).to_json
      end

      GobiertoData::Cache.dataset_cache(dataset, format: 'csv', update: true) do
        GobiertoData::Connection.execute_query_output_csv(dataset.site, dataset.rails_model.all.to_sql, { col_sep: "," })
      end

      GobiertoData::Cache.dataset_cache(dataset, format: 'xlsx', update: true) do
        GobiertoData::Connection.execute_query_output_xlsx(dataset.site, dataset.rails_model.all.to_sql, { name: dataset.name })
      end
    end
  end
end
