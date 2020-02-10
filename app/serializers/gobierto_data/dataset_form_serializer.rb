# frozen_string_literal: true

module GobiertoData
  class DatasetFormSerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers
    include ::GobiertoCommon::HasCustomFieldsAttributes

    attributes(
      :id,
      :name,
      :name_translations,
      :table_name,
      :data_updated_at,
      :slug,
      :data_path,
      :local_data,
      :csv_separator,
      :schema,
      :append,
      :visibility_level
    )

    def current_site
      Site.find_by(id: object.site_id) || instance_options[:site]
    end

    def exclude_links?
      instance_options[:exclude_links]
    end

  end
end
