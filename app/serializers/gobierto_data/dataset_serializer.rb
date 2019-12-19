# frozen_string_literal: true

module GobiertoData
  class DatasetSerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers
    include ::GobiertoCommon::HasCustomFieldsAttributes

    attributes :id, :name, :slug, :updated_at

    attribute :links, unless: :exclude_links? do
      slug = object.slug
      {
        data: gobierto_data_api_v1_dataset_path(slug),
        metadata: meta_gobierto_data_api_v1_dataset_path(slug)
      }
    end

    def current_site
      Site.find_by(id: object.site_id) || instance_options[:site]
    end

    def exclude_links?
      instance_options[:exclude_links]
    end

  end
end
