# frozen_string_literal: true

require_dependency "gobierto_data"

module GobiertoData
  class Visualization < ApplicationRecord
    include GobiertoData::Favoriteable

    belongs_to :query
    belongs_to :user
    has_one :dataset, through: :query
    enum privacy_status: { open: 0, closed: 1 }

    translates :name

    scope :active, -> { joins(:dataset).where(GobiertoData::Dataset.table_name => { visibility_level: GobiertoData::Dataset.visibility_levels[:active] }) }

    validates :query, :user, :name, presence: true
    delegate :site, :dataset, :visibility_level, to: :query

    def result(include_draft: false)
      return unless sql.present?

      Connection.execute_query(site, sql, include_draft: include_draft)
    end
  end
end
