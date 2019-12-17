# frozen_string_literal: true

module GobiertoData
  class QuerySerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers

    attributes :id
    attribute :name, unless: :with_translations?
    attribute :name_translations, if: :with_translations?
    attributes :privacy_status, :sql, :dataset_id, :user_id
    belongs_to :dataset
    belongs_to :user
    has_many :visualizations

    attribute :links, unless: :exclude_links? do
      id = object.id
      {
        data: gobierto_data_api_v1_query_path(id),
        metadata: meta_gobierto_data_api_v1_query_path(id)
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
