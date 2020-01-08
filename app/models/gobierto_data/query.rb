# frozen_string_literal: true

require_dependency "gobierto_data"

module GobiertoData
  class Query < ApplicationRecord
    belongs_to :dataset
    belongs_to :user
    has_many :visualizations, dependent: :destroy
    enum privacy_status: { open: 0, closed: 1 }

    translates :name

    delegate :site, to: :dataset

    def result
      Connection.execute_query(site, sql)
    end
  end
end
