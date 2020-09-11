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

    class_methods do
      def favorited_by_user(user, parent: nil)
        return none unless user.present?

        parent ||= user.site
        association_name = module_parent.class.reflect_on_all_associations(:has_many).find { |association| association.options[:class_name] == name }&.name

        return none unless association_name.present?

        parent.send(association_name).joins(:favorites).where(GobiertoData::Favorite.table_name => { user_id: user&.id })
      end
    end
  end
end
