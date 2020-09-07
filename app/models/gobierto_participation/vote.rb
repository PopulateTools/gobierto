# frozen_string_literal: true

module GobiertoParticipation
  class Vote < ApplicationRecord
    belongs_to :votable, polymorphic: true, counter_cache: true
    belongs_to :user
    belongs_to :site

    validates :site, :user, :votable_id, :votable_type, :vote_weight, presence: true
  end
end
