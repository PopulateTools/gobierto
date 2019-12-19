# frozen_string_literal: true

module GobiertoData
  class DatasetMetaSerializer < DatasetSerializer
    has_many :queries
    has_many :visualizations

    attribute :data_summary do
      {
        number_of_rows: object.rails_model.count
      }
    end

    attribute :data_preview do
      object.rails_model.first(50)
    end
  end
end
