# frozen_string_literal: true

module GobiertoData
  class CacheDatasetsMetadata < ActiveJob::Base
    queue_as :cached_data

    def perform(dataset)
      dataset.rows_count
    end
  end
end
