# frozen_string_literal: true

class AddNameTranslationsAndSlugToVocabularies < ActiveRecord::Migration[5.2]
  def up
    add_column :vocabularies, :name_translations, :jsonb
    add_column :vocabularies, :slug, :string
    GobiertoCommon::Vocabulary.all.each do |vocabulary|
      vocabulary.update_columns(name_translations: localized_name_attr(vocabulary), slug: slug(vocabulary))
    end
    remove_column :vocabularies, :name
  end

  def down
    add_column :vocabularies, :name, :string
    GobiertoCommon::Vocabulary.all.each do |vocabulary|
      vocabulary.update_columns(name: delocalized_name_attr(vocabulary))
    end
    remove_column :vocabularies, :slug
    remove_column :vocabularies, :name_translations
  end

  def localized_name_attr(vocabulary)
    { vocabulary.site.configuration.default_locale => vocabulary.attributes["name"] }
  end

  def slug(vocabulary)
    slug_core = vocabulary.attributes["name"].tr(" ", "_").parameterize
    return slug_core unless vocabulary.site.vocabularies.where(slug: slug_core).exists?

    "#{slug_core}-#{vocabulary.site.vocabularies.where(slug: slug_core).count + 1}"
  end

  def delocalized_name_attr(vocabulary)
    vocabulary.name_translations[vocabulary.site.configuration.default_locale.to_s]
  end
end
