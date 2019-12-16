# frozen_string_literal: true

module GobiertoData
  class VisualizationSerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers

    attributes :id
    attribute :name, unless: :with_translations?
    attribute :name_translations, if: :with_translations?
    attributes :privacy_status, :spec, :query_id, :user_id
    belongs_to :query
    belongs_to :user

    attribute :links, unless: :exclude_links? do
      dataset_slug = object.dataset.slug
      query_id = object.query_id
      id = object.id
      {
        show: gobierto_data_api_v1_dataset_query_visualization_path(dataset_slug: dataset_slug, query_id: query_id, id: id)
      }
    end

    def current_site
      Site.find(object.site.id)
    end

    def exclude_links?
      instance_options[:exclude_links]
    end

    def with_translations?
      instance_options[:with_translations]
    end
  end
end
