# frozen_string_literal: true

module GobiertoData
  class QueryMetaSerializer < QuerySerializer
    attribute :formats do
      id = object.id
      object.dataset.available_formats.inject({}) do |formats, format|
        formats.update(
          format => download_gobierto_data_api_v1_query_path(id, format: format)
        )
      end
    end
  end
end
