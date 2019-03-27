# frozen_string_literal: true

require_dependency "gobierto_admin"

module GobiertoAdmin
  class CensusImport < ApplicationRecord
    belongs_to :site
    belongs_to :admin

    scope :sorted, -> { order(created_at: :desc) }
    scope :completed, -> { where(completed: true) }

    def self.latest_by_site(site)
      completed.sorted.where(site: site).first
    end
  end
end
