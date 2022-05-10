# frozen_string_literal: true

module GobiertoData
  class CacheDatasetsMetadata < ActiveJob::Base
    queue_as :cached_data

    def perform(dataset)
      GobiertoData::DatasetMetaSerializer.new(dataset).to_json
    end
  end
end
