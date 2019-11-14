# frozen_string_literal: true

require_dependency "gobierto_data"

module GobiertoData
  class Dataset < ApplicationRecord
    include GobiertoCommon::Sluggable

    belongs_to :site

    translates :name

    validates :site, :name, :slug, :table_name, presence: true
    validates :slug, uniqueness: { scope: :site_id }

    def attributes_for_slug
      [name]
    end
  end
end
