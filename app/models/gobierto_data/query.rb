# frozen_string_literal: true

require_dependency "gobierto_data"

module GobiertoData
  class Query < ApplicationRecord
    include GobiertoData::Favoriteable

    belongs_to :dataset
    belongs_to :user
    has_many :visualizations, dependent: :destroy, class_name: "GobiertoData::Visualization"
    enum privacy_status: { open: 0, closed: 1 }

    translates :name

    delegate :site, to: :dataset

    def result
      Connection.execute_query(site, sql)
    end

    def file_basename
      [dataset.slug, name].join("-").tr("_", " ").parameterize
    end
  end
end
