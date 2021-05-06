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
            vocabulary.terms.create(name_translations: { ca: "Anual",      en: "Annual",    es: "Anual" },      description_translations: { ca: 365, en: 365, es:  365 }, position: 1)
            vocabulary.terms.create(name_translations: { ca: "Trimestral", en: "Quarterly", es: "Trimestral" }, description_translations: { ca: 120, en: 120, es: 120 }, position: 2)
            vocabulary.terms.create(name_translations: { ca: "Mensual",    en: "Monthly",   es: "Mensual" },    description_translations: { ca:  30, en:  30, es:   30 }, position: 3)
            vocabulary.terms.create(name_translations: { ca: "Diària",     en: "Daily",     es: "Diaria" },     description_translations: { ca:   1, en:   1, es:    1 }, position: 4)
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
            vocabulary.terms.create(name_translations: { ca: "Creative Commons BY",       en: "Creative Commons BY",       es: "Creative Commons BY"       }, position: 1)
            vocabulary.terms.create(name_translations: { ca: "Creative Commons BY-SA",    en: "Creative Commons BY-SA",    es: "Creative Commons BY-SA"    }, position: 2)
            vocabulary.terms.create(name_translations: { ca: "Creative Commons BY-ND",    en: "Creative Commons BY-ND",    es: "Creative Commons BY-ND"    }, position: 3)
            vocabulary.terms.create(name_translations: { ca: "Creative Commons BY-NC",    en: "Creative Commons BY-NC",    es: "Creative Commons BY-NC"    }, position: 4)
            vocabulary.terms.create(name_translations: { ca: "Creative Commons BY-NC-SA", en: "Creative Commons BY-NC-SA", es: "Creative Commons BY-NC-SA" }, position: 5)
            vocabulary.terms.create(name_translations: { ca: "Creative Commons BY-NC-ND", en: "Creative Commons BY-NC-ND", es: "Creative Commons BY-NC-ND" }, position: 6)
            vocabulary.terms.create(name_translations: { ca: "Open Data (ODbl)",          en: "Open Data (ODbl)",          es: "Open Data (ODbl)"          }, position: 7)
            vocabulary.terms.create(name_translations: { ca: "Open Data (ODC-BY)",        en: "Open Data (ODC-BY)",        es: "Open Data (ODC-BY)"        }, position: 8)
            vocabulary.terms.create(name_translations: { ca: "Open Data (PDDL)",          en: "Open Data (PDDL)",          es: "Open Data (PDDL)"          }, position: 9)
          end
          license.name_translations =  { ca: "Llicència", en: "License", es: "Licencia" }
          license.position = 6
          license.options = {
            configuration: { vocabulary_type: "single_select" },
            vocabulary_id: vocabulary.id.to_s
          }
          license.save
        end

        publisher_organism = site.custom_fields.string.where(class_name: "Site").find_or_initialize_by(uid: "catalog-publisher")
        if publisher_organism.new_record?
          publisher_organism.name_translations = { ca: "URL Organisme publicador", en: "Organism publisher URL", es: "URL Organisme publicador" }
          publisher_organism.position = 1
          publisher_organism.options = { configuration: {} }
          publisher_organism.save

          custom_field_record = GobiertoCommon::CustomFieldRecord.new
          custom_field_record.item_type = "Site"
          custom_field_record.item_id = site.id
          custom_field_record.custom_field_id =  publisher_organism.id
          custom_field_record.payload = { "no-translatable": "http://datos.gob.es/recurso/sector-publico/org/Organismo/L01280650" } # https://datos.gob.es/recurso/sector-publico/org/Organismo#search
          custom_field_record.save
        end

        publisher_spatial = site.custom_fields.string.where(class_name: "Site").find_or_initialize_by(uid: "catalog-spatials")
        if publisher_spatial.new_record?
          publisher_spatial.name_translations = { ca: "Organisme publicador spatials", en: "Organism publisher spatials", es: "URL Organisme spatials" }
          publisher_spatial.position = 2
          publisher_spatial.options = { configuration: {} }
          publisher_spatial.save

          custom_field_record = GobiertoCommon::CustomFieldRecord.new
          custom_field_record.item_type = "Site"
          custom_field_record.item_id = site.id
          custom_field_record.custom_field_id = publisher_spatial.id
          custom_field_record.payload = {"no-translatable": [
            "http://datos.gob.es/recurso/sector-publico/territorio/Pais/España",
            "http://datos.gob.es/recurso/sector-publico/territorio/Autonomia/Madrid",
            "http://datos.gob.es/recurso/sector-publico/territorio/Provincia/Madrid",
            "https://datos.gob.es/recurso/sector-publico/territorio/Ciudad/Getafe"       #FIXME
          ]}
          custom_field_record.save
        end

        publisher_taxonomy = site.custom_fields.string.where(class_name: "Site").find_or_initialize_by(uid: "catalog-theme-taxonomy")
        if publisher_taxonomy.new_record?
          publisher_taxonomy.name_translations = { ca: "Tema (taxonomia gob.es)", en: "Theme (taxonomia gob.es)", es: "Tema (taxonomia gob.es)" }
          publisher_taxonomy.position = 3
          publisher_taxonomy.options = { configuration: {} }
          publisher_taxonomy.save

          custom_field_record = GobiertoCommon::CustomFieldRecord.new
          custom_field_record.item_type = "Site"
          custom_field_record.item_id = site.id
          custom_field_record.custom_field_id = publisher_taxonomy.id
          custom_field_record.payload = { "no-translatable": "http://datos.gob.es/kos/sector-publico/sector/sector-publico" }
          custom_field_record.save
        end
      end

    end
  end
end
