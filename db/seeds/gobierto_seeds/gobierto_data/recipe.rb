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
          dataset_source_url.name_translations = { ca: "Enllaç a origen", en: "Link to Source", es: "Enlace a la Fuente" }
          dataset_source_url.position = 5
          dataset_source_url.options = { configuration: {} }
          dataset_source_url.save
        end

        license = site.custom_fields.vocabulary_options.where(class_name: "GobiertoData::Dataset").find_or_initialize_by(uid: 'dataset-license')
        if license.new_record?
          vocabulary = site.vocabularies.find_or_initialize_by(slug: "dataset-license")
          if vocabulary.new_record?
            vocabulary.name_translations = { ca: "Llicència", en: "License", es: "Licencia" }
            vocabulary.save
            vocabulary.terms.create(
              name_translations: {
                ca: "Creative Commons BY",
                en: "Creative Commons BY",
                es: "Creative Commons BY"
              },
              description_translations: {
                ca: "https://creativecommons.org/licenses/by/4.0/deed.cat",
                en: "https://creativecommons.org/licenses/by/4.0/deed.en",
                es: "https://creativecommons.org/licenses/by/4.0/deed.es"},
              position: 1)
            vocabulary.terms.create(
              name_translations: {
                ca: "Creative Commons BY-SA",
                en: "Creative Commons BY-SA",
                es: "Creative Commons BY-SA"},
              description_translations: {
                ca: "https://creativecommons.org/licenses/by-sa/3.0/deed.cat",
                en: "https://creativecommons.org/licenses/by-sa/3.0/deed.en",
                es: "https://creativecommons.org/licenses/by-sa/3.0/deed.es"},
              position: 2)
            vocabulary.terms.create(
              name_translations: {
                ca: "Creative Commons BY-ND",
                en: "Creative Commons BY-ND",
                es: "Creative Commons BY-ND"},
              description_translations: {
                ca: "https://creativecommons.org/licenses/by-nd/2.0/deed.cat",
                en: "https://creativecommons.org/licenses/by-nd/2.0/deed.en",
                es: "https://creativecommons.org/licenses/by-nd/2.0/deed.es"},
              position: 3)
            vocabulary.terms.create(
              name_translations: {
                ca: "Creative Commons BY-NC",
                en: "Creative Commons BY-NC",
                es: "Creative Commons BY-NC"},
              description_translations: {
                ca: "https://creativecommons.org/licenses/by-nc/2.0/deed.cat",
                en: "https://creativecommons.org/licenses/by-nc/2.0/deed.en",
                es: "https://creativecommons.org/licenses/by-nc/2.0/deed.es"},
              position: 4)
            vocabulary.terms.create(
              name_translations: {
                ca: "Creative Commons BY-NC-SA",
                en: "Creative Commons BY-NC-SA",
                es: "Creative Commons BY-NC-SA"},
              description_translations: {
                ca: "https://creativecommons.org/licenses/by-nc-sa/3.0/deed.cat",
                en: "https://creativecommons.org/licenses/by-nc-sa/3.0/deed.en",
                es: "https://creativecommons.org/licenses/by-nc-sa/3.0/deed.es"},
              position: 5)
            vocabulary.terms.create(
              name_translations: {
                ca: "Creative Commons BY-NC-ND",
                en: "Creative Commons BY-NC-ND",
                es: "Creative Commons BY-NC-ND"},
              description_translations: {
                ca: "https://creativecommons.org/licenses/by-nc-nd/3.0/deed.cat",
                en: "https://creativecommons.org/licenses/by-nc-nd/3.0/deed.en",
                es: "https://creativecommons.org/licenses/by-nc-nd/3.0/deed.es"},
              position: 6)
            vocabulary.terms.create(
              name_translations: {
                ca: "Open Data (ODbl)",
                en: "Open Data (ODbl)",
                es: "Open Data (ODbl)"},
            description_translations: {
              ca: "https://opendatacommons.org/licenses/odbl/1-0/",
              en: "https://opendatacommons.org/licenses/odbl/1-0/",
              es: "https://opendatacommons.org/licenses/odbl/1-0/"},
            position: 7)
            vocabulary.terms.create(
              name_translations: {
                ca: "Open Data (ODC-BY)",
                en: "Open Data (ODC-BY)",
                es: "Open Data (ODC-BY)"},
              description_translations: {
                ca: "https://opendatacommons.org/licenses/by/1-0/",
                en: "https://opendatacommons.org/licenses/by/1-0/",
                es: "https://opendatacommons.org/licenses/by/1-0/"},
              position: 8)
            vocabulary.terms.create(
              name_translations: {
                ca: "Open Data (PDDL)",
                en: "Open Data (PDDL)",
                es: "Open Data (PDDL)"},
              description_translations: {
                ca: "https://opendatacommons.org/licenses/pddl/",
                en: "https://opendatacommons.org/licenses/pddl/",
                es: "https://opendatacommons.org/licenses/pddl/"},
              position: 9)
          end
          license.name_translations =  { ca: "Llicència", en: "License", es: "Licencia" }
          license.position = 6
          license.options = {
            configuration: { vocabulary_type: "single_select" },
            vocabulary_id: vocabulary.id.to_s
          }
          license.save
        end

        dataset_default_geometry = site.custom_fields.string.where(class_name: "GobiertoData::Dataset").find_or_initialize_by(uid: 'gobierto-default-geometry-data-column')
        if dataset_default_geometry.new_record?
          dataset_default_geometry.name_translations = { ca: "Columna per llegir dades de geometria", en: "Column to read geometry data", es: "Columna para leer datos de geometría" }
          dataset_default_geometry.position = 7
          dataset_default_geometry.options = { configuration: {} }
          dataset_default_geometry.save
        end
      end
    end
  end
end
