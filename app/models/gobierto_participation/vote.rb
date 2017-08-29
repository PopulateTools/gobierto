# frozen_string_literal: true

require_dependency "gobierto_participation"

module GobiertoParticipation
  class Vote < ApplicationRecord
    belongs_to :votable, polymorphic: true, counter_cache: true
    belongs_to :user
    belongs_to :site
  end
end
