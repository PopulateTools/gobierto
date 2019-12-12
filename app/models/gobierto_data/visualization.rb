# frozen_string_literal: true

require_dependency "gobierto_data"

module GobiertoData
  class Visualization < ApplicationRecord

    belongs_to :query
    belongs_to :user

    translates :name

    validates :query, :user, :name, presence: true
    delegate :site, to: :query

  end
end
