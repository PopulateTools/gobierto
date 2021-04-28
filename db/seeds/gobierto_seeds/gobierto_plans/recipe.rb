# frozen_string_literal: true

module GobiertoSeeds
  module GobiertoPlans
    class Recipe

      def self.run(site)
        # Create vocabulary
        vocabulary = site.vocabularies.find_or_initialize_by(slug: "sdgs-vocabulary")
        if vocabulary.new_record?
          vocabulary.name_translations = { ca: "Vocabulari d'ODSs", en: "SDGs vocabulary", es: "Vocabulario de ODSs" }
          vocabulary.save
        end

        return if vocabulary.terms.present?

        # Load terms
        import_form = GobiertoAdmin::GobiertoCommon::VocabularyTermsImportForm.new(
          vocabulary: vocabulary,
          csv_file: Rails.root.join("db/seeds/gobierto_seeds/gobierto_plans/sdgs_seeds.csv")
        )
        import_form.save
      end
    end
  end
end
