# frozen_string_literal: true

module GobiertoData
  def self.table_name_prefix
    "gdata_"
  end

  def self.classes_with_custom_fields
    [GobiertoData::Dataset]
  end

  def self.root_path(_current_site)
    Rails.application.routes.url_helpers.gobierto_data_root_path
  end

  def self.attachments_collection(current_site)
    current_site.collections.find_by(container_type: "GobiertoData", item_type: "GobiertoAttachments::Attachment")
  end

  def self.attachments_collection!(current_site)
    attachments_collection(current_site) || create_attachments_collection(current_site)
  end

  def self.api_settings(current_site)
    OpenStruct.new(::GobiertoModuleSettings.find_by(site: current_site, module_name: "GobiertoData")&.api_settings)
  end

  def self.create_attachments_collection(current_site)
    current_site.collections.create!(
      container_type: "GobiertoData",
      item_type: "GobiertoAttachments::Attachment",
      slug: "gobierto-data-attachments",
      title_translations: {
        "ca" => "Documents de Dades",
        "en" => "Data documents",
        "es" => "Documentos de Datos"
      }.slice(*current_site.configuration.available_locales)
    )
  end

  def self.searchable_models
    [ GobiertoData::Dataset ]
  end
end
