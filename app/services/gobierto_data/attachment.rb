module GobiertoData
  class Attachment
    def self.attachments_collection(current_site)
      current_site.collections.find_by(container_type: "GobiertoData", item_type: "GobiertoAttachments::Attachment")
    end

    def self.attachments_collection!(current_site)
      attachments_collection(current_site) || create_attachments_collection(current_site)
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
  end
end
