# frozen_string_literal: true

require_dependency "gobierto_participation"

module GobiertoParticipation
  class ContributorContainer < ApplicationRecord
    include User::Subscribable

    translates :title, :description

    belongs_to :site

    enum visibility_level: { draft: 0, active: 1 }
    enum contribution_type: { idea: 0, question: 1, proposal: 2 }

    validates :site, :title, :description, presence: true
  end
end
