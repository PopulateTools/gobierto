# frozen_string_literal: true

require_dependency "gobierto_participation"

module GobiertoParticipation
  class Comment < ApplicationRecord
    include GobiertoParticipation::Flaggable
    include GobiertoParticipation::Votable

    belongs_to :commentable, polymorphic: true, counter_cache: true
    belongs_to :user
    belongs_to :site

    validates :body, :user, presence: true
  end
end
