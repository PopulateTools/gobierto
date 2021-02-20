# frozen_string_literal: true

require_relative "../gobierto_data"

module GobiertoData
  class Query < ApplicationRecord
    include GobiertoData::Favoriteable

    belongs_to :dataset
    belongs_to :user
    has_many :visualizations, dependent: :nullify, class_name: "GobiertoData::Visualization"
    enum privacy_status: { open: 0, closed: 1 }

    translates :name

    scope :active, -> { joins(:dataset).where(GobiertoData::Dataset.table_name => { visibility_level: GobiertoData::Dataset.visibility_levels[:active] }) }

    delegate :site, :visibility_level, to: :dataset

    def result(include_draft: false, include_stats: false)
      Connection.execute_query(site, sql, include_draft: include_draft, include_stats: include_stats)
    end

    def csv_result(csv_options_params, include_draft: false)
      GobiertoData::Connection.execute_query_output_csv(site, sql, csv_options_params, include_draft: include_draft)
    end

    def file_basename
      [dataset.slug, name].join("-").tr("_", " ").parameterize
    end
  end
end
