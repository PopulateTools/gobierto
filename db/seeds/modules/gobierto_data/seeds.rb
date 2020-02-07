# frozen_string_literal: true

module GobiertoSeeds
  class Recipe
    def self.run(site)
      description = site.custom_fields.localized_string.where(class_name: "GobiertoData::Dataset").find_or_initialize_by(uid: "description")
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
          vocabulary.name_translations = { ca: "Freqüència", en: "Frequency", es: "Frecuencia" }
          vocabulary.save
          vocabulary.terms.create(name_translations: { ca: "Anual", en: "Annual", es: "Anual" })
          vocabulary.terms.create(name_translations: { ca: "Trimestral", en: "Quarterly", es: "Trimestral" })
          vocabulary.terms.create(name_translations: { ca: "Mensual", en: "Monthly", es: "Mensual" })
          vocabulary.terms.create(name_translations: { ca: "Diària", en: "Daily", es: "Diaria" })
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
      return unless category.new_record?

      vocabulary = site.vocabularies.find_or_initialize_by(slug: "datasets-category")
      if vocabulary.new_record?
        vocabulary.name_translations = { ca: "Categoria", en: "Category", es: "Categoría" }
        vocabulary.save
        vocabulary.terms.create(name_translations: { ca: "General", en: "General", es: "General" })
      end
      category.name_translations = { ca: "Categoria", en: "Category", es: "Categoría" }
      category.position = 3
      category.options = {
        configuration: { vocabulary_type: "single_select" },
        vocabulary_id: vocabulary.id.to_s
      }
      category.save
    end
  end
end
