# frozen_string_literal: true

require_relative "../gobierto_dashboards"

module GobiertoDashboards
  class Dashboard < ApplicationRecord
    belongs_to :site

    scope :sorted, -> { order(data_updated_at: :desc) }

    translates :title

    enum visibility_level: { draft: 0, active: 1 }

    validates :site, presence: true
  end
end
