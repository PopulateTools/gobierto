# frozen_string_literal: true

module GobiertoData
  class DatasetMetaSerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers
    include ::GobiertoCommon::HasCustomFieldsAttributes

    cache key: "dataset_meta"

    attributes :id, :name, :slug, :table_name, :data_updated_at

    has_many :queries
    has_many :visualizations
    has_many :attachments

    attribute :links, unless: :exclude_links? do
      slug = object.slug
      {
        data: gobierto_data_api_v1_dataset_path(slug),
        metadata: meta_gobierto_data_api_v1_dataset_path(slug),
        stats: stats_gobierto_data_api_v1_dataset_path(slug)
      }
    end

    attribute :columns do
      if model_present?
        object.rails_model.columns.inject({}) do |columns, column|
          columns.update(
            column.name => column.type
          )
        end
      end
    end

    attribute :data_summary do
      count_result = ::GobiertoData::Connection.execute_query(
        object.site,
        Arel.sql("SELECT COUNT(1) FROM #{object.table_name} LIMIT 1"),
        include_draft: true
      )
      {
        number_of_rows: count_result.is_a?(PG::Result) ? count_result.first.dig("count") : nil
      }
    end

    attribute :formats do
      object.available_formats.inject({}) do |formats, format|
        formats.update(
          format => download_gobierto_data_api_v1_dataset_path(object.slug, format: format)
        )
      end
    end

    def current_site
      Site.find_by(id: object.site_id) || instance_options[:site]
    end

    def exclude_links?
      instance_options[:exclude_links]
    end

    def model_present?
      object.rails_model.present? && object.rails_model.table_exists?
    end

  end
end
