# frozen_string_literal: true

module GobiertoSeeds
  module GobiertoPlans
    class Recipe
      include GobiertoCommon::ModuleNamePrefixable

      def self.run(site)
        sdgs = ::GobiertoCommon::Vocabulary::RESERVED.fetch(:sdgs)

        # Create vocabulary
        vocabulary = site.vocabularies.find_or_initialize_by(slug: sdgs[:slug])
        if vocabulary.new_record?
          vocabulary.name_translations = prefix_translations(sdgs[:name_translations])
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
