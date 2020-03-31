# frozen_string_literal: true

module GobiertoSeeds
  class Recipe

    def self.run(site)
      # Create sdg vocabulary
      return if site.custom_fields.vocabulary_options.where(uid: "sdgs").exists?

      # Create vocabulary
      vocabulary = site.vocabularies.find_or_initialize_by(slug: "sdgs-vocabulary")
      if vocabulary.new_record?
        vocabulary.name_translations = { ca: "Vocabulari d'ODSs", en: "SDGs vocabulary", es: "Vocabulario de ODSs" }
        vocabulary.save
      end

      # Load terms
      import_form = GobiertoAdmin::GobiertoCommon::VocabularyTermsImportForm.new(
        vocabulary: vocabulary,
        csv_file: Rails.root.join("db/seeds/modules/gobierto_plans/sdgs_seeds.csv")
      )
      import_form.save

      # Create custom field
      class_name = "GobiertoPlans::Node"
      custom_field = site.custom_fields.vocabulary_options.create(
        uid: "sdgs",
        name_translations: {
          ca: "Objectius de Desenvolupament Sostenible",
          en: "Sustainable Development Goals",
          es: "Objetivos de Desarrollo Sostenible"
        },
        class_name: class_name,
        options: {
          configuration: { vocabulary_type: "multiple_select" },
          vocabulary_id: vocabulary.id
        }
      )
      custom_field.update_attribute(:position, (site.custom_fields.where(class_name: class_name).maximum(:position) || 0) + 1)
    end
  end
end
