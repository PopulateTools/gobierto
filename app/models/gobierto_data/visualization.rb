# frozen_string_literal: true

module GobiertoData
  class Visualization < ApplicationRecord
    include GobiertoData::Favoriteable

    belongs_to :dataset
    belongs_to :query, optional: true
    belongs_to :user
    enum privacy_status: { open: 0, closed: 1 }

    translates :name

    scope :active, -> { joins(:dataset).where(GobiertoData::Dataset.table_name => { visibility_level: GobiertoData::Dataset.visibility_levels[:active] }) }

    validates :dataset, :user, :name, presence: true
    delegate :site, :visibility_level, to: :dataset

    def result(include_draft: false)
      return unless sql.present?

      Connection.execute_query(site, sql, include_draft: include_draft)
    end
  end
end
