# frozen_string_literal: true

module GobiertoData
  class Favorite < ApplicationRecord
    belongs_to :user
    belongs_to :favorited, polymorphic: true

    validates :user_id, uniqueness: { scope: [:favorited_type, :favorited_id] }

    delegate :site, to: :user

    scope :recent, -> { order(created_at: :desc) }
  end
end
