# frozen_string_literal: true

module GobiertoData
  class DatasetMetaSerializer < DatasetSerializer
    include Rails.application.routes.url_helpers

    has_many :queries
    has_many :visualizations

    attribute :data_summary do
      {
        number_of_rows: object.rails_model.count
      }
    end

    attribute :columns do
      object.rails_model.columns.inject({}) do |columns, column|
        columns.update(
          column.name => column.type
        )
      end
    end

    attribute :formats do
      object.available_formats.inject({}) do |formats, format|
        formats.update(
          format => download_gobierto_data_api_v1_dataset_path(object.slug, format: format)
        )
      end
    end

    attribute :data_preview do
      object.rails_model.first(50)
    end
  end
end
