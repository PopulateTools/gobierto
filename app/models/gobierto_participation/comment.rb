# frozen_string_literal: true

require_dependency "gobierto_participation"

module GobiertoParticipation
  class Comment < ApplicationRecord
    include GobiertoParticipation::Flaggable

    belongs_to :commentable, polymorphic: true, counter_cache: true
    belongs_to :user
    belongs_to :site
    has_many :votes

    validates :body, :user, presence: true
  end
end
