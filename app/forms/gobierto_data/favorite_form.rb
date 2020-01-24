# frozen_string_literal: true

module GobiertoData
  class FavoriteForm < BaseForm
    include ::GobiertoCore::TranslationsHelpers

    attr_accessor(
      :site_id,
      :favorited,
      :user_id
    )

    validates :site, :user, :favorited, presence: true

    delegate :persisted?, to: :favorite

    def favorite
      @favorite ||= build_favorite
    end

    def user
      @user ||= site.presence && site.users.find_by(id: user_id)
    end

    def site
      @site ||= Site.find_by(id: site_id)
    end

    def save
      save_favorite if valid?
    end

    private

    def build_favorite
      favorite_class.new
    end

    def favorite_class
      Favorite
    end

    def save_favorite
      @favorite = favorite.tap do |attributes|
        attributes.user_id = user.id
        attributes.favorited = favorited
      end

      return @favorite if @favorite.save

      promote_errors(@favorite.errors)

      false
    end
  end
end
