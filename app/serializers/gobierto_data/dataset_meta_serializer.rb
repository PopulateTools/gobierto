# frozen_string_literal: true

module GobiertoData
  class DatasetMetaSerializer < DatasetSerializer
    attribute :rows_count do
      object.rails_model.count
    end
  end
end
