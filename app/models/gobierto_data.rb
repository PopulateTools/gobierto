# frozen_string_literal: true

module GobiertoData
  def self.table_name_prefix
    "gdata_"
  end

  def self.classes_with_custom_fields
    [GobiertoData::Dataset]
  end

  def self.root_path(current_site)
    Rails.application.routes.url_helpers.gobierto_data_root_path
  end
end
