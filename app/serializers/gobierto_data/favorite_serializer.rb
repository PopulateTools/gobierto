# frozen_string_literal: true

module GobiertoData
  class FavoriteSerializer < ActiveModel::Serializer
    attributes :id, :user_id, :favorited_type, :favorited_id
    belongs_to :user, unless: :exclude_relationships?
    belongs_to :favorited, polymorphic: true, unless: :exclude_relationships?

    def current_site
      Site.find(object.site.id)
    end

    def exclude_relationships?
      instance_options[:exclude_relationships]
    end
  end
end
