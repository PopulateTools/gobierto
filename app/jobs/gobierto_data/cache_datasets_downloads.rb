# frozen_string_literal: true

module GobiertoData
  class CacheDatasetsDownloads < ActiveJob::Base
    queue_as :cached_data

    def perform(dataset)
      GobiertoData::Cache.dataset_cache(dataset, format: 'csv', update: true) do
        GobiertoData::Connection.execute_query_output_csv(dataset.site, dataset.rails_model.all.to_sql, { col_sep: "," })
      end
    end
  end
end
