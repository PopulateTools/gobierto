# frozen_string_literal: true

module GobiertoSeeds
  module GobiertoData
    class Recipe
      DEFAULT_CATEGORY_NAMES = [
        "Ciencia y tecnología",
        "Comercio",
        "Cultura y ocio",
        "Demografía",
        "Deporte",
        "Economía",
        "Educación",
        "Empleo",
        "Energía",
        "Hacienda",
        "Industria",
        "Legislación y justicia",
        "Medio Rural",
        "Medio ambiente",
        "Salud",
        "Sector público",
        "Seguridad",
        "Sociedad y bienestar",
        "Transporte",
        "Turismo",
        "Urbanismo e infraestructuras",
        "Vivienda"
      ].freeze

      def self.run(site)
        # Initialize module collection
        ::GobiertoData::Attachment.attachments_collection!(site)

        description = site.custom_fields.localized_paragraph.where(class_name: "GobiertoData::Dataset").find_or_initialize_by(uid: "description")
        if description.new_record?
          description.name_translations = { ca: "Descripció", en: "Description", es: "Descripción" }
          description.position = 1
          description.options = { configuration: {} }
          description.save
        end

        frequency = site.custom_fields.vocabulary_options.where(class_name: "GobiertoData::Dataset").find_or_initialize_by(uid: "frequency")
        if frequency.new_record?
          vocabulary = site.vocabularies.find_or_initialize_by(slug: "datasets-frequency")
          if vocabulary.new_record?
            vocabulary.name_translations = { ca: "Freqüència de conjunt de dades", en: "Dataset frequency", es: "Frecuencia de conjunto de datos" }
            vocabulary.save
            vocabulary.terms.create(name_translations: { ca: "Anual", en: "Annual", es: "Anual" }, position: 1)
            vocabulary.terms.create(name_translations: { ca: "Trimestral", en: "Quarterly", es: "Trimestral" }, position: 2)
            vocabulary.terms.create(name_translations: { ca: "Mensual", en: "Monthly", es: "Mensual" }, position: 3)
            vocabulary.terms.create(name_translations: { ca: "Diària", en: "Daily", es: "Diaria" }, position: 4)
          end
          frequency.name_translations = { ca: "Freqüència", en: "Frequency", es: "Frecuencia" }
          frequency.position = 2
          frequency.options = {
            configuration: { vocabulary_type: "single_select" },
            vocabulary_id: vocabulary.id.to_s
          }
          frequency.save
        end

        category = site.custom_fields.vocabulary_options.where(class_name: "GobiertoData::Dataset").find_or_initialize_by(uid: "category")
        if category.new_record?
          vocabulary = site.vocabularies.find_or_initialize_by(slug: "datasets-category")
          if vocabulary.new_record?
            vocabulary.name_translations = { ca: "Categoria de conjunt de dades", en: "Dataset Category", es: "Categoría de conjunto de datos" }
            vocabulary.save
            DEFAULT_CATEGORY_NAMES.each_with_index do |category_name, index|
              vocabulary.terms.create(
                name_translations: Hash[site.configuration.available_locales.product([category_name])],
                position: index + 1
              )
            end
          end
          category.name_translations = { ca: "Categoria", en: "Category", es: "Categoría" }
          category.position = 3
          category.options = {
            configuration: { vocabulary_type: "multiple_select" },
            vocabulary_id: vocabulary.id.to_s
          }
          category.save
        end

        dataset_source_license = site.custom_fields.string.where(class_name: "GobiertoData::Dataset").find_or_initialize_by(uid: "dataset-source")
        if dataset_source_license.new_record?
          dataset_source_license.name_translations = { ca: "Origen", en: "Source", es: "Fuente" }
          dataset_source_license.position = 4
          dataset_source_license.options = { configuration: {} }
          dataset_source_license.save
        end

        dataset_source_url = site.custom_fields.string.where(class_name: "GobiertoData::Dataset").find_or_initialize_by(uid: "dataset-source-url")
        if dataset_source_url.new_record?
          dataset_source_url.name_translations = { ca: "Enllaç a llicència", en: "Link to License", es: "Enlace a Licencia" }
          dataset_source_url.position = 5
          dataset_source_url.options = { configuration: {} }
          dataset_source_url.save
        end

        licenses = site.custom_fields.vocabulary_options.where(class_name: "GobiertoData::Dataset").find_or_initialize_by(uid: 'dataset-license')
        if licenses.new_record?
          vocabulary = site.vocabularies.find_or_initialize_by(slug: "dataset-license")
          if vocabulary.new_record?
            vocabulary.name_translations = { ca: "Llicència", en: "License", es: "Licencia" }
            vocabulary.save
            vocabulary.terms.create(name_translations: { ca: "Open Data (ODbl)",   en: "Open Data (ODbl)",   es: "Open Data (ODbl)" }, position: 1)
            vocabulary.terms.create(name_translations: { ca: "Open Data (ODC-By)", en: "Open Data (ODC-By)", es: "Open Data (ODC-By)" }, position: 2)
            vocabulary.terms.create(name_translations: { ca: "Open Data (PDDL)",   en: "Open Data (PDDL)",   es: "Open Data (PDDL)" }, position: 3)
          end
          licenses.name_translations =  { ca: "Llicència", en: "License", es: "Licencia" }
          licenses.position = 6
          licenses.options = {
            configuration: { vocabulary_type: "single_select" },
            vocabulary_id: vocabulary.id.to_s
          }
          licenses.save
        end
      end
    end
  end
end
