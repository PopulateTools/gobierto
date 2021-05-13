require_relative "../gobierto_data"

module GobiertoData
  class Neighbourhood < ApplicationRecord
    belongs_to :site
    belongs_to :dataset

    validates :site, :dataset, :name, :geometry, presence: true
  end
end
