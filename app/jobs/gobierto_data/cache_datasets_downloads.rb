# frozen_string_literal: true

module GobiertoData
  class CacheDatasetsDownloads < ActiveJob::Base
    queue_as :default

    def perform(*datasets)
      datasets.each do |dataset|
        cached_data = CachedData.new(dataset)

        cached_data.source("download.json", update: true) do
          Connection.execute_query(dataset.site, dataset.rails_model.all.to_sql).to_json
        end

        %w(, ;).each do |separator|
          csv_options_params = { col_sep: separator }
          cached_data.source("download_#{csv_options_params.to_query}.csv", update: true) do
            Connection.execute_query_output_csv(dataset.site, dataset.rails_model.all.to_sql, csv_options_params)
          end
        end

        cached_data.source("download.xlsx", update: true) do
          Connection.execute_query_output_xlsx(dataset.site, dataset.rails_model.all.to_sql, { name: dataset.name }).read
        end
      end
    end
  end
end
