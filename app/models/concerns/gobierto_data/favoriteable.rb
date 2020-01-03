# frozen_string_literal: true

module GobiertoData
  module Favoriteable
    extend ActiveSupport::Concern

    included do
      has_many :favorites, as: :favorited, dependent: :destroy

      def favorited_by_user?(user)
        favorites.exists?(user_id: user.id)
      end
    end
  end
end
