# frozen_string_literal: true

module GobiertoData
  class CacheDatasetsDownloads < ActiveJob::Base
    queue_as :cached_data

    def perform(*datasets)
      datasets.each do |dataset|
        file_basename = dataset.slug
        cached_data = CachedData.new(dataset)

        cached_data.source("#{file_basename}.json", update: true) do
          Connection.execute_query(dataset.site, dataset.rails_model.all.to_sql).to_json
        end

        # Download cache only supports comma separated CSVs
        cached_data.source("#{file_basename}.csv", update: true) do
          Connection.execute_query_output_csv(dataset.site, dataset.rails_model.all.to_sql, { col_sep: "," })
        end

        cached_data.source("#{file_basename}.xlsx", update: true) do
          Connection.execute_query_output_xlsx(dataset.site, dataset.rails_model.all.to_sql, { name: dataset.name }).read
        end
      end
    end
  end
end
