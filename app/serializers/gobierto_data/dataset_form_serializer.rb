# frozen_string_literal: true

module GobiertoData
  class DatasetFormSerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers
    include ::GobiertoCommon::HasCustomFieldsAttributes

    attributes :id, :name, :name_translations, :table_name, :slug, :data_path, :csv_separator, :schema, :append

    def current_site
      Site.find_by(id: object.site_id) || instance_options[:site]
    end

    def exclude_links?
      instance_options[:exclude_links]
    end

  end
end
