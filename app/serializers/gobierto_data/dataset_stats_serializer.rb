# frozen_string_literal: true

module GobiertoData
  class DatasetStatsSerializer < DatasetSerializer
    attribute :columns_stats do
      object.columns_stats
    end
  end
end
