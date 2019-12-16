# frozen_string_literal: true

require_dependency "gobierto_data"

module GobiertoData
  class Visualization < ApplicationRecord
    belongs_to :query
    belongs_to :user
    enum privacy_status: { open: 0, closed: 1 }

    translates :name

    validates :query, :user, :name, presence: true
    delegate :site, :dataset, to: :query
  end
end
