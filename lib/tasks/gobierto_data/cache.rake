# frozen_string_literal: true

namespace :gobierto_data do
  desc "Forces datasets download cache"
  task cache_dataset_downloads: :environment do
    GobiertoData::Dataset.find_each do |dataset|
      GobiertoData::CacheDatasetsDownloads.perform_later(dataset)
    end
  end

  desc "Expire queries cache"
  task expire_queries_cache: :environment do
    GobiertoData::Cache.expire_queries_cache
  end
end
