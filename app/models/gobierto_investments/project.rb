# frozen_string_literal: true

module GobiertoInvestments
  class Project < ApplicationRecord
    belongs_to :site

    translates :title

    validates :site, :title, presence: true
    validates :external_id, uniqueness: { scope: :site_id, allow_nil: true }
  end
end
